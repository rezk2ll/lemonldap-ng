## @file
# OpenID SREG extension for Lemonldap::NG::Portal::IssuerOpenID class

## @class
# OpenID SREG extension for Lemonldap::NG::Portal::IssuerOpenID class

package Lemonldap::NG::Portal::OpenID::SREG;

use strict;
use Lemonldap::NG::Common::Regexp;
use constant { OI_INVALID => 1, };

## @method protected hash sregHook(hash prm)
# Hook called to add SREG parameters to the OpenID response
# @return Hash containing wanted parameters
sub sregHook {
    my ( $self, $u, $trust_root, $is_id, $is_trusted, $prm ) = splice @_;
    my ( %r, @req, @opt );

    return 0 unless (%$prm);
    return ( 0, $prm ) unless ($is_id);

    my %msg;

    # TODO: verify that request has been accepted
    my $accepted = 1;
    while ( my ( $k, $v ) = each %$prm ) {
        if ( $k eq 'policy_url' ) {
            if ( $v =~ Lemonldap::NG::Common::Regexp::HTTP_URI ) {
                $msg{policy} = $v;
                my $p =
                  $self->{sessionInfo}->{"_openidTrust$trust_root\_Policy"};
                $accepted = 0 unless ( $p and $p eq $v );
            }
            else {
                $self->lmLog( "Bad policy url", 'error' );
            }
        }
        elsif ( $k eq 'required' ) {
            push @req, split( /,/, $v );
        }
        elsif ( $k eq 'optional' ) {
            push @opt,
              grep { defined $self->{"openIdSreg_$_"} } split( /,/, $v );
        }
        else {
            $self->lmLog( "Unknown OpenID SREG request $k", 'error' );
        }
    }

    # Check if required keys are valid SREG requests
    if (
        my @tmp =
        map { s/\W/\./sg }
        grep
/^(?:(?:(?:full|nick)nam|languag|postcod|timezon)e|country|gender|email|dob)$/,
        @req, @opt
      )
    {
        $self->lmLog(
            "Requested parameter(s) "
              . join( ',', @tmp )
              . "is(are) not valid OpenID SREG parameter",
            'error'
        );
        return prompt( $self, OI_INVALID, $prm, \%msg );
    }

    # If a required data is not available, returns nothing
    foreach my $k (@req) {
        unless ( $self->{"openIdSreg_$k"} ) {
            $self->lmLog(
"Parameter $k is required by customer but not defined in configuration",
                'notice'
            );

            # TODO
            #return prompt( $self, OI_);
            return ( 0, {} );
        }
    }
    foreach my $k ( @req, @opt ) {
        $r{$k} = $self->{sessionInfo}->{ $self->{"openIdSreg_$k"} } || '';
    }

    # TODO: return 0 is federation has not been accepted
    return 1, \%r;
}

sub prompt {
    return ( 0, {} );
}

1;

