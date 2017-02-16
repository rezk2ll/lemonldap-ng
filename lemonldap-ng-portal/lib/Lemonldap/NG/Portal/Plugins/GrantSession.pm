package Lemonldap::NG::Portal::Plugins::GrantSession;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
  PE_SESSIONNOTGRANTED
);

extends 'Lemonldap::NG::Portal::Main::Plugin';

use constant afterDatas => 'grantSession';

has rules => ( is => 'rw', default => sub { {} } );

sub init {
    my ($self) = @_;
    my $hd = $self->p->HANDLER;
    foreach ( keys %{ $self->conf->{grantSessionRule} } ) {
        my $rule =
          $hd->buildSub(
            $hd->substitute( $self->conf->{grantSessionRule}->{$_} ) );
        unless ($rule) {
            $self->error( "Bad grantSession rule " . $hd->tsv->{jail}->error );
            return 0;
        }
        $self->rules->{$_} = $rule;
    }
    return 1;
}

sub grantSession {
    my ( $self, $req ) = @_;

    sub sortByComment {
        my $A = ( $a =~ /^.*?##(.*)$/ )[0];
        my $B = ( $b =~ /^.*?##(.*)$/ )[0];
        return !$A ? 1 : !$B ? -1 : $A cmp $B;
    }
    foreach ( sort sortByComment keys %{ $self->rules } ) {
        $self->logger->debug("Grant session condition \"$_\"");
        unless ( $self->rules->{$_}->( $req->sessionInfo ) ) {
            $self->userLogger->error( 'User '
                  . $req->user
                  . " was not granted to open session (rule $_)" );
            return PE_SESSIONNOTGRANTED;
        }
    }
    return PE_OK;
}

1;
