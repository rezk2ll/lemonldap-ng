package Lemonldap::NG::Portal::Plugins::AdaptativeAuthenticationLevel;

use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
);

our $VERSION = '2.0.10';

extends 'Lemonldap::NG::Portal::Main::Plugin';

use constant afterData => 'adaptAuthenticationLevel';

has rules => ( is => 'rw', default => sub { {} } );

sub init {
    my ($self) = @_;
    $self->logger->debug('Init AdaptativeAuthenticationLevel plugin');
    my $hd = $self->p->HANDLER;
    foreach (
        keys %{ $self->conf->{adaptativeAuthenticationLevelRules} // {} } )
    {
        $self->logger->debug("adaptativeAuthenticationLevelRules key -> $_");
        $self->logger->debug( "adaptativeAuthenticationLevelRules value -> "
              . $self->conf->{adaptativeAuthenticationLevelRules}->{$_} );
        my $rule = $hd->buildSub( $hd->substitute($_) );
        unless ($rule) {
            my $error = $hd->tsv->{jail}->error || '???';
            $self->logger->error(
                "Bad AdaptativeAuthenticationLevel rule -> $error");
            $self->logger->debug(
                "Skipping AdaptativeAuthenticationLevel rule \"$_\"");
            next;
        }
        $self->rules->{$_} = $rule;
    }
    return 1;
}

sub adaptAuthenticationLevel {
    my ( $self, $req ) = @_;

    my $userid = $req->user;
    $self->logger->debug("Check adaptative authentication rules for $userid");

    my $authenticationLevel = $req->sessionInfo->{authenticationLevel};
    $self->logger->debug(
        "Current authentication level for $userid is $authenticationLevel");

    my $updatedAuthenticationLevel = $authenticationLevel;

    sub sortByComment {

        my $A = ( $a =~ /^.*?##(.*)$/ )[0];
        my $B = ( $b =~ /^.*?##(.*)$/ )[0];
        return !$A ? 1 : !$B ? -1 : $A cmp $B;
    }

    foreach ( sort sortByComment keys %{ $self->rules } ) {
        my $rule = $_;
        $self->logger->debug(
            "Check adaptativeAuthenticationLevelRules -> $rule");
        if ( $self->rules->{$_}->( $req, $req->sessionInfo ) ) {
            my $levelOperation =
              $self->conf->{adaptativeAuthenticationLevelRules}->{$_};
            $self->logger->debug(
"User $userid match rule, apply $levelOperation on authentication level"
            );

            my ( $op, $level ) = ( $levelOperation =~ /([=+-])?(\d+)/ );
            $updatedAuthenticationLevel = $level if ( !$op or $op eq '=' );
            $updatedAuthenticationLevel += $level if ( $op and $op eq '+' );
            $updatedAuthenticationLevel -= $level if ( $op and $op eq '-' );
            $self->logger->debug(
"Authentication level for $userid is now $updatedAuthenticationLevel"
            );
        }
    }

    if ( $authenticationLevel ne $updatedAuthenticationLevel ) {
        $self->logger->debug(
            "Authentication level has changed for $userid, update session");
        $self->p->updateSession(
            $req,
            {
                'authenticationLevel' => $updatedAuthenticationLevel
            }
        );

    }

    return PE_OK;
}

1;
