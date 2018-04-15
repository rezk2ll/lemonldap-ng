package Lemonldap::NG::Manager::2ndFA;

use 5.10.0;
use utf8;
use strict;
use Mouse;
use MIME::Base64 qw(encode_base64 decode_base64);

use Lemonldap::NG::Common::Session;
use Lemonldap::NG::Common::Conf::Constants;
use Lemonldap::NG::Common::PSGI::Constants;
use Lemonldap::NG::Common::Conf::ReConstants;

use feature 'state';

extends 'Lemonldap::NG::Common::Conf::AccessLib',
  'Lemonldap::NG::Common::Session::REST';

our $VERSION = '2.0.0';

#############################
# I. INITIALIZATION METHODS #
#############################

use constant defaultRoute => '2ndfa.html#/persistent';

sub addRoutes {
    my ( $self, $conf ) = @_;

    # Remote Procedure Call are defined in Lemonldap::NG::Common::Session::REST
    # HTML template
    $self->addRoute( '2ndfa.html', undef, ['GET'] )

      ->addRoute(
        sfa => { ':sessionType' => 'sfa' },
        ['GET']
      )

      # DELETE 2FA DEVICE
      ->addRoute(
        sfa => { ':sessionType' => { ':sessionId' => 'delete2FA' } },
        ['DELETE']
      );

      ## ADD 2FA DEVICE
      #->addRoute(
        #sfa => { ':sessionType' => { ':sessionId' => 'add2FA' } },
        #['PUT']
      #)

      ## VERIFY 2FA DEVICE
      #->addRoute(
        #sfa => { ':sessionType' => { ':sessionId' => 'verify2FA' } },
        #['POST']
      #);

    $self->setTypes($conf);

    $self->{ipField}              ||= 'ipAddr';
    $self->{multiValuesSeparator} ||= '; ';
    $self->{hiddenAttributes} //= "_password";
    $self->{TOTPCheck} = '1';
    $self->{U2FCheck}  = '1';
    $self->{UBKCheck}  = '1';
}

###################
# II. 2FA METHODS #
###################

sub delete2FA {

    my ( $self, $req, $session, $skey ) = @_;

    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );

    my $params = $req->parameters();
    my $Key    = $params->{Key};

    if ( $Key =~ /\bU2F\b/ ) {
        $self->logger->debug("Call procedure deleteU2F");
        return $self->deleteU2F( $req, $session, $skey );
    }
    elsif ( $Key =~ /\bTOTP\b/ ) {
        $self->logger->debug("Call procedure deleteTOTP");
        return $self->deleteTOTP( $req, $session, $skey );
    }
    elsif ( $Key =~ /\bUBK\b/ ) {
        $self->logger->debug("Call procedure deleteUBK");
        return $self->deleteUBK( $req, $session, $skey );
    }
    else {
        return $self->sendError( $req, undef, 400 );
    }
}

#sub add2FA {

    #my ( $self, $req, $session, $skey ) = @_;

    #eval 'use Crypt::U2F::Server::Simple';
    #if ($@) {
        #$self->error("Can't load U2F library: $@");
        #return 0;
    #}

    #return $self->addU2FKey( $req, $session, $skey );
#}

#sub verify2FA {

    #my ( $self, $req, $session, $skey ) = @_;

    #return $self->addU2FKey( $req, $session, $skey );
#}

########################
# III. DISPLAY METHODS #
########################

sub sfa {
    my ( $self, $req, $session, $skey ) = @_;

    # Case 1: only one session is required
    if ($session) {

        return $self->session( $req, $session, $skey );
    }

    my $mod = $self->getMod($req)
      or return $self->sendError( $req, undef, 400 );
    my $params = $req->parameters();
    my $type   = delete $params->{sessionType};
    $type = ucfirst($type);
    my $res;

    # Case 2: list of sessions

    my $whatToTrace = Lemonldap::NG::Handler::PSGI::Main->tsv->{whatToTrace};

    # 2.1 Get fields to require
    my @fields = (
        '_httpSessionType', $self->{ipField},
        $whatToTrace,       '_2fDevices'
    );
    if ( my $groupBy = $params->{groupBy} ) {
        $groupBy =~ s/^substr\((\w+)(?:,\d+(?:,\d+)?)?\)$/$1/;
        $groupBy =~ s/^_whatToTrace$/$whatToTrace/o
          or push @fields, $groupBy;
    }
    else {
        push @fields, '_utime';
    }

    # 2.2 Restrict query if possible: search for filters (any query arg that is
    #     not a keyword)
    my $moduleOptions = $mod->{options};
    $moduleOptions->{backend} = $mod->{module};

    # Select 2FA sessions to display
    if ( defined $params->{TOTPCheck} or defined $params->{U2FCheck} or defined $params->{UBKCheck}) {
        $self->{TOTPCheck} = delete $params->{TOTPCheck};
        $self->{U2FCheck}  = delete $params->{U2FCheck};
        $self->{UBKCheck}  = delete $params->{UBKCheck};
    }

    my %filters = map {
        my $s = $_;
        $s =~ s/\b_whatToTrace\b/$whatToTrace/o;
        /^groupBy$/
          ? ()
          : ( $s => $params->{$_} );
    } keys %$params;
    $filters{_session_kind} = $type;

    push @fields, keys(%filters);
    {
        my %seen;
        @fields = grep { !$seen{$_}++ } @fields;
    }

    # For now, only one argument can be passed to
    # Lemonldap::NG::Common::Apache::Session so just the first filter is
    # used
    my ($firstFilter) = sort {
            $filters{$a} =~ m#^[\w:]+/\d+\*?$# ? 1
          : $filters{$b} =~ m#^[\w:]+/\d+\*?$# ? -1
          : $a eq '_session_kind'              ? 1
          : $b eq '_session_kind'              ? -1
          : $a cmp $b
    } keys %filters;

    # Check if a '*' is required
    my $function = 'searchOn';
    $function = 'searchOnExpr'
      if ( grep { /\*/ and not m#^[\w:]+/\d+\*?$# }
        ( $filters{$firstFilter} ) );
    $self->logger->debug(
        "First filter: $firstFilter = $filters{$firstFilter} ($function)");

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

    delete $filters{$firstFilter}
      unless ( grep { /\*/ and not m#^[\w:]+/\d+\*?$# }
        ( $filters{$firstFilter} ) );
    foreach my $k ( keys %filters ) {
        $self->logger->debug("Removing unless $k =~ /^$filters{$k}\$/");
        if ( $filters{$k} =~ m#^([\w:]+)/(\d+)\*?$# ) {
            my ( $net, $bits ) = ( $1, $2 );
            foreach my $session ( keys %$res ) {
                delete $res->{$session}
                  unless ( net6( $res->{$session}->{$k}, $bits ) eq $net );
            }
        }
        else {
            $filters{$k} =~ s/\./\\./g;
            $filters{$k} =~ s/\*/\.\*/g;
            foreach my $session ( keys %$res ) {
                if ( $res->{$session}->{$k} ) {
                    delete $res->{$session}
                      unless ( $res->{$session}->{$k} =~ /^$filters{$k}$/ );
                }
            }
        }
    }

    # Filter 2FA sessions if needed
    if ( $self->{U2FCheck} eq '2' ) {
        foreach my $session ( keys %$res ) {
            delete $res->{$session}
              unless ( defined $res->{$session}->{_2fDevices}
                and $res->{$session}->{_2fDevices} =~ /"type":\s*"U2F"/s );
        }
    }
    if ( $self->{TOTPCheck} eq '2' ) {
        foreach my $session ( keys %$res ) {
            delete $res->{$session}
              unless ( defined $res->{$session}->{_2fDevices}
                and $res->{$session}->{_2fDevices} =~ /"type":\s*"TOTP"/s );
        }
    }
    if ( $self->{UBKCheck} eq '2' ) {
        foreach my $session ( keys %$res ) {
            delete $res->{$session}
              unless ( defined $res->{$session}->{_2fDevices}
                and $res->{$session}->{_2fDevices} =~ /"type":\s*"UBK"/s );
        }
    }

    my $total = ( keys %$res );

    if ( my $group = $req->params('groupBy') ) {
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
            sort {
                my @a = ( $a->{value} =~ /^(\d+)(?:\.(\d+))*$/ );
                my @b = ( $b->{value} =~ /^(\d+)(?:\.(\d+))*$/ );
                ( @a and @b )
                  ? ( $a[0] <=> $b[0]
                      or $a[1] <=> $b[1]
                      or $a[2] <=> $b[2]
                      or $a[3] <=> $b[3] )
                  : $a->{value} cmp $b->{value}
              }
              map { { value => $_, count => $r->{$_} } } keys %$r
        ];
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
