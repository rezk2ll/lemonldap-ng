package Lemonldap::NG::Manager::Sessions;

use 5.10.0;
use utf8;
use strict;
use Mouse;

use Lemonldap::NG::Common::Session;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Common::Session;
use Lemonldap::NG::Common::PSGI::Constants;
use Lemonldap::NG::Common::Conf::ReConstants;

use feature 'state';

extends 'Lemonldap::NG::Common::Conf::AccessLib',
  'Lemonldap::NG::Common::Session::REST';

our $VERSION = '2.0.0';

#############################
# I. INITIALIZATION METHODS #
#############################

use constant defaultRoute => 'sessions.html';

sub addRoutes {
    my ( $self, $conf ) = @_;

    # HTML template
    $self->addRoute( 'sessions.html', undef, ['GET'] )

      # READ
      ->addRoute( sessions => { ':sessionType' => 'sessions' }, ['GET'] )

      # DELETE
      ->addRoute(
        sessions => { ':sessionType' => { ':sessionId' => 'delSession' } },
        ['DELETE']
      );

    $self->setTypes($conf);

    $self->{ipField}              ||= 'ipAddr';
    $self->{multiValuesSeparator} ||= '; ';
    $self->{hiddenAttributes} //= "_password";
}

#######################
# II. DISPLAY METHODS #
#######################

sub sessions {
    my ( $self, $req, $session, $skey ) = @_;

    # Case 1: only one session is required
    if ($session) {
        return $self->session( $req, $session, $skey );
    }

    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );
    my $params = $req->parameters();
    my $type   = delete $params->{sessionType};
    $type = $type eq 'global' ? 'SSO' : ucfirst($type);

    my $res;

    # Case 2: list of sessions

    my $whatToTrace = Lemonldap::NG::Handler::PSGI::Main->tsv->{whatToTrace};

    # 2.1 Get fields to require
    my @fields = ( '_httpSessionType', $self->{ipField}, $whatToTrace );
    if ( my $groupBy = $params->{groupBy} ) {
        $groupBy =~ s/^substr\((\w+)(?:,\d+(?:,\d+)?)?\)$/$1/
          or $groupBy =~ s/^net4\((\w+),\d\)$/$1/;
        $groupBy =~ s/^_whatToTrace$/$whatToTrace/o
          or push @fields, $groupBy;
    }
    elsif ( my $order = $params->{orderBy} ) {
        $order =~ s/^net4\((\w+)\)$/$1/;
        $order =~ s/^_whatToTrace$/$whatToTrace/o
          or push @fields, split( /, /, $order );
    }
    else {
        push @fields, '_utime';
    }

    # 2.2 Restrict query if possible: search for filters (any query arg that is
    #     not a keyword)
    my $moduleOptions = $mod->{options};
    $moduleOptions->{backend} = $mod->{module};
    my %filters = map {
        my $s = $_;
        $s =~ s/\b_whatToTrace\b/$whatToTrace/o;
        /^(?:(?:group|order)By|doubleIp)$/
          ? ()
          : ( $s => $params->{$_} );
    } keys %$params;
    $filters{_session_kind} = $type;

    # Check if a '*' is required
    my $function = 'searchOn';
    $function = 'searchOnExpr' if ( grep /\*/, values %filters );

    # For now, only one argument can be passed to
    # Lemonldap::NG::Common::Apache::Session so just the first filter is
    # used
    my ($firstFilter) = sort {
            $a eq '_session_kind' ? 1
          : $b eq '_session_kind' ? -1
          : $a cmp $b
    } keys %filters;
    $res =
      Lemonldap::NG::Common::Apache::Session->$function( $moduleOptions,
        $firstFilter, $filters{$firstFilter}, @fields );

    return $self->sendJSONresponse(
        $req,
        {
            result => 1,
            count  => 0,
            total  => 0,
            values => []
        }
    ) unless ( $res and %$res );

    delete $filters{$firstFilter};
    foreach my $k ( keys %filters ) {
        $filters{$k} =~ s/\*/\.\*/g;
        foreach my $session ( keys %$res ) {
            if ( $res->{$session}->{$k} ) {
                delete $res->{$session}
                  unless ( $res->{$session}->{$k} =~ /^$filters{$k}$/ );
            }
        }
    }

    my $total = ( keys %$res );

    # 2.4 Special case doubleIp (users connected from more than 1 IP)
    if ( defined $params->{doubleIp} ) {
        my %r;

        # 2.4.1 Store user IP addresses in %r
        foreach my $id ( keys %$res ) {
            my $entry = $res->{$id};
            next if ( $entry->{_httpSessionType} );
            $r{ $entry->{$whatToTrace} }->{ $entry->{ $self->{ipField} } }++;
        }

   # 2.4.2 Store sessions owned by users that has more than one IP address in $r
        my $r;
        $total = 0;
        foreach my $k ( keys %$res ) {
            my @tmp = keys %{ $r{ $res->{$k}->{$whatToTrace} } };
            if ( @tmp > 1 ) {
                $total += 1;
                $res->{$k}->{_sessionId} = $k;
                push @{ $r->{ $res->{$k}->{$whatToTrace} } }, $res->{$k};
            }
        }

        # 2.4.3 Store these session in an array. Array elements are :
        #       {
        #           uid      => whatToTraceFieldValue,
        #           sessions => [
        #               { session => <session-id-1>, date => <_utime> },
        #               { session => <session-id-2>, date => <_utime> },
        #           ]
        #       }
        $res = [];
        foreach my $uid ( sort keys %$r ) {
            push @$res, {
                value    => $uid,
                count    => scalar( @{ $r->{$uid} } ),
                sessions => [
                    map {
                        {
                            session => $_->{_sessionId},
                            date    => $_->{_utime}
                        }
                    } @{ $r->{$uid} }
                ]
            };
        }
    }

 # 2.4 Order and group by
 # $res will become an array ref here (except for doubleIp, already done below).

    # If "groupBy" is asked, elements will be like:
    #   { uid => 'foo.bar', count => 3 }
    elsif ( my $group = $req->params('groupBy') ) {
        my $r;
        $group =~ s/\b_whatToTrace\b/$whatToTrace/o;

        # Substrings
        if ( $group =~ /^substr\((\w+)(?:,(\d+)(?:,(\d+))?)?\)$/ ) {
            my ( $field, $length, $start ) = ( $1, $2, $3 );
            $start ||= 0;
            $length = 1 if ( $length < 1 );
            foreach my $k ( keys %$res ) {
                $r->{ substr $res->{$k}->{$field}, $start, $length }++
                  if ( $res->{$k}->{$field} );
            }
            $group = $field;
        }

        # Subnets
        elsif ( $group =~ /^net4\((\w+),(\d)\)$/ ) {
            my $field = $1;
            my $nb    = $2 - 1;
            foreach my $k ( keys %$res ) {
                if ( $res->{$k}->{$field} =~ /^((((\d+)\.\d+)\.\d+)\.\d+)$/ ) {
                    my @d = ( $4, $3, $2, $1 );
                    $r->{ $d[$nb] }++;
                }
            }
            $group = $field;
        }

        # Simple field groupBy query
        elsif ( $group =~ /^\w+$/ ) {
            eval {
                foreach my $k ( keys %$res ) {
                    $r->{ $res->{$k}->{$group} }++;
                }
            };
            return $self->sendError(
                $req,
qq{Use of an uninitialized attribute "$group" to group sessions},
                400
            ) if ($@);
        }
        else {
            return $self->sendError( $req, 'Syntax error in groupBy', 400 );
        }

        # Build result
        $res = [
            sort { $a->{value} cmp $b->{value} }
            map { { value => $_, count => $r->{$_} } } keys %$r
        ];
    }

    # Else if "orderBy" is asked, $res elements will be like:
    #   { uid => 'foo.bar', session => <sessionId> }
    elsif ( my $f = $req->params('orderBy') ) {
        my @fields = split /,/, $f;
        my @r = map {
            my $tmp = { session => $_ };
            foreach my $f (@fields) {
                my $s = $f;
                $s =~ s/^net4\((\w+)\)$/$1/;
                $tmp->{$s} = $res->{$_}->{$s};
            }
            $tmp
        } keys %$res;
        while ( my $f = pop @fields ) {
            if ( $f =~ s/^net4\((\w+)\)$/$1/ ) {
                @r = sort {
                    my @a = split /\./, $a->{$f};
                    my @b = split /\./, $b->{$f};
                    my $cmp = 0;
                  F: for ( my $i = 0 ; $i < 4 ; $i++ ) {
                        if ( $a[$i] != $b[$i] ) {
                            $cmp = $a[$i] <=> $b[$i];
                            last F;
                        }
                    }
                    $cmp;
                } @r;
            }
            else {
                @r = sort { $a->{$f} cmp $b->{$f} } @r;
            }
        }
        $res = [@r];
    }

    # Else, $res elements will be like:
    #   { session => <sessionId>, date => <timestamp> }
    else {
        $res = [
            sort { $a->{date} <=> $b->{date} }
              map { { session => $_, date => $res->{$_}->{_utime} } }
              keys %$res
        ];
    }

    return $self->sendJSONresponse(
        $req,
        {
            result => 1,
            count  => scalar(@$res),
            total  => $total,
            values => $res
        }
    );
}

1;
