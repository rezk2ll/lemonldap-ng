## @file
# OpenID SREG extension for Lemonldap::NG::Portal::Issuer::OpenID class

## @class
# OpenID SREG extension for Lemonldap::NG::Portal::Issuer::OpenID class

package Lemonldap::NG::Portal::Lib::OpenID::SREG;

use strict;
use Lemonldap::NG::Common::Regexp;

## @method protected hash sregHook(hash prm)
# Hook called to add SREG parameters to the OpenID response
# @return Hash containing wanted parameters
sub sregHook {
    my ( $self, $req, $u, $trust_root, $is_id, $is_trusted, $prm ) = @_;
    my ( @req, @opt );

    # Refuse federation if rejected by user
    if ( $req->param('confirm') and $req->param('confirm') == -1 ) {
        my %h;
        $h{$_} = undef foreach (
            qw(fullname nickname language postcode timezone country gender email dob)
        );
        $self->p->updatePersistentSession( \%h );
        return 0;
    }

    # If identity is not trusted, does nothing
    return ( 0, $prm ) unless ( $is_id and $is_trusted );

    $self->lmLog( "SREG start", 'debug' );

    my $accepted = 1;

    # Check all parameters
    while ( my ( $k, $v ) = each %$prm ) {

        # Store policy if provided
        if ( $k eq 'policy_url' ) {
            if ( $v =~ Lemonldap::NG::Common::Regexp::HTTP_URI ) {
                $req->datas->{_openIdTrustExtMsg} .=
                    '<dl><dt trspan="openidPA">' . "&nbsp;:</dt><dd><a href=\"$v\">$v</a></dd></dl>";

                # Question: is it important to notify policy changes ?
                # if yes, uncomment this
                #my $p =
                #  $req->{sessionInfo}->{"_openidTrust$trust_root\_Policy"};
                #$accepted = 0 unless ( $p and $p eq $v );
            }
            else {
                $self->lmLog( "Bad policy url", 'error' );
            }
        }

        # Parse required attributes
        elsif ( $k eq 'required' ) {
            $self->lmLog( "Required attr $v", 'debug' );
            push @req, split( /,/, $v );
        }

        # Parse optional attributes
        elsif ( $k eq 'optional' ) {
            $self->lmLog( "Optional attr $v", 'debug' );
            push @opt, grep { defined $self->conf->{"openIdSreg_$trust_root$_"} }
              split( /,/, $v );
        }
        else {
            $self->lmLog( "Unknown OpenID SREG request $k", 'error' );
        }
    }

    # Check if required keys are valid SREG requests
    # Question: reject bad SREG request ? Not done yet
    @req = sregfilter( $self, @req );
    @opt = sregfilter( $self, @opt );

    # Return if nothing is asked
    return ( 1, {} ) unless ( @req or @opt );

    # If a required data is not available, returns nothing
    foreach my $k (@req) {
        unless ( $self->conf->{"openIdSreg_$k"} ) {
            $self->lmLog(
"Parameter $k is required by $trust_root but not defined in configuration",
                'notice'
            );

            $req->info( qq'<h3 trspan="openidRpns,$k"></h3>');
            return ( 0, {} );
        }
    }

    # Now set datas
    my ( %r, %msg, %ag, %toStore );

    # Requested parameters: check if already agreed or confirm is set
    foreach my $k (@req) {
        my $agree = $req->{sessionInfo}->{"_openidTrust$trust_root\_$k"};
        if ($accepted) {
            unless ( $req->param('confirm') or $agree ) {
                $accepted = 0;
            }
            elsif ( !$agree ) {
                $toStore{"_openidTrust$trust_root\_$k"} = 1;
            }
        }
        my $tmp = $self->conf->{"openIdSreg_$k"};
        $tmp =~ s/^\$//;
        $msg{req}->{$k} = $r{$k} =
          $req->{sessionInfo}->{ $self->{"openIdSreg_$k"} } || '';
    }

    # Optional parameters:
    foreach my $k (@opt) {
        my $tmp = $self->conf->{"openIdSreg_$k"};
        $tmp =~ s/^\$//;
        my $agree = $req->{sessionInfo}->{"_openidTrust$trust_root\_$k"};
        if ($accepted) {

            # First, check if already accepted
            unless ( $req->param('confirm') or defined($agree) ) {
                $accepted = 0;
                $r{$k} = $req->{sessionInfo}->{$tmp}
                  || '';
            }

            # If confirmation is returned, check the value for this field
            elsif ( $req->param('confirm') == 1 ) {
                my $ck = 0;
                if ( defined( $req->param("sreg_$k") ) ) {
                    $ck = ( $req->param("sreg_$k") eq 'OK' ) || 0;
                }

                # Store the value returned
                if ( !defined($agree) or $agree != $ck ) {
                    $toStore{"_openidTrust$trust_root\_$k"} = $ck;
                    $agree = $ck;
                }
            }
        }

        $msg{opt}->{$k} = $req->{sessionInfo}->{$tmp} || '';

        # Store the value only if user agree it
        if ($agree) {
            $r{$k}  = $msg{opt}->{$k};
            $ag{$k} = 1;
        }
        elsif ( !defined($agree) ) {
            $ag{$k} = 1;
        }
        else {
            $ag{$k} = 0;
        }
    }
    $self->p->updatePersistentSession( \%toStore ) if (%toStore);

    # Check if user has agreed request
    if ($accepted) {
        $self->p->userInfo(
            $req->{sessionInfo}->{ $self->conf->{whatToTrace} }
              . " has accepted OpenID SREG exchange with $trust_root" );
        return ( 1, \%r );
    }

    # else build message and return 0
    else {

        $req->datas->{_openIdTrustExtMsg} .= qq'<h3 trspan="openidAp"></h3>';

        $req->datas->{_openIdTrustExtMsg} .= "<table class=\"openidsreg\">\n";

        # No choice for requested parameters: just an information
        foreach my $k (@req) {
            utf8::decode( $msg{req}->{$k} );
            $req->datas->{_openIdTrustExtMsg} .=
                "<tr class=\"required\">\n" . "<td>"
              . "<input type=\"checkbox\" disabled=\"disabled\" checked=\"checked\"/>"
              . "</td>\n"
              . "<td>$k</td>\n" . "<td>"
              . $msg{req}->{$k}
              . "</td>\n"
              . "</tr>\n";
        }

        # For optional parameters: checkboxes are displayed
        foreach my $k (@opt) {
            utf8::decode( $msg{opt}->{$k} );
            $req->datas->{_openIdTrustExtMsg} .=
                "<tr class=\"optional\">\n"
              . "<td>\n"
              . "<input type=\"checkbox\" value=\"OK\""
              . ( $ag{$k} ? 'checked="checked"' : '' )
              . " name=\"sreg_$k\" />"
              . "</td>\n"
              . "<td>$k</td>\n" . "<td>"
              . $msg{opt}->{$k}
              . "</td>\n"
              . "</tr>\n";
        }

        $req->datas->{_openIdTrustExtMsg} .= "</table>\n";

        $self->lmLog( 'Building validation form', 'debug' );
        return ( 0, $prm );
    }
}

## @method private array sregfilter(array attr)
# Filter the arguments passed as parameters by checking their compliance with
# SREG.
# @return fitered datas
sub sregfilter {
    my ( $self, @attr ) = @_;
    my ( @ret, @rej );

    # Browse attributes
    foreach my $s (@attr) {
        if ( $s =~
/^(?:(?:(?:full|nick)nam|languag|postcod|timezon)e|country|gender|email|dob)$/
          )
        {
            push @ret, $s;
        }
        else {
            $s =~ s/\W/\./sg;
            push @rej, $s;
        }
    }

    # Warn if some parameters are rejected
    if (@rej) {
        $self->lmLog(
            "Requested parameter(s) "
              . join( ',', @rej )
              . "is(are) not valid OpenID SREG parameter(s)",
            'warn'
        );
    }

    # Return valid SREG parameters
    return @ret;
}
1;
