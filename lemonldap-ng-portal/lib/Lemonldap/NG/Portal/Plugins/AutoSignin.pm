package Lemonldap::NG::Portal::Plugins::AutoSignin;

use strict;
use Mouse;
use Safe;
use Lemonldap::NG::Portal::Main::Constants qw(
  PE_OK
);

our $VERSION = '2.0.0';

extends 'Lemonldap::NG::Portal::Main::Plugin';

# INTERFACE

use constant beforeAuth => 'check';

# INITIALIZATION

has rules => ( is => 'rw', default => sub { [] } );

sub init {
    my ($self) = @_;
    if ( my $rules = $self->conf->{autoLoginRules} ) {
        my $safe = Safe->new;
        foreach my $r ( sort keys %$rules ) {
            my $sub = $safe->reval("sub{my(\$env)=\@_;return ($r)}");
            if ($@) {
                $self->error(qq'Bad Autologin rule "$r": $@');
                return 0;
            }
            my $name = $rules->{$r};
            $name =~ s/^\s*([\w\-\@]+)\s*/$1/;
            push @{ $self->rules }, [ $sub, $name ];
        }
    }
    return 1;
}

# RUNNING METHODS

sub check {
    my ( $self, $req ) = @_;

    foreach ( @{ $self->rules } ) {
        my ( $test, $name ) = @$_;
        if ( $test->( $req->env ) ) {
            $req->user($name);
            my @steps =
              grep { !ref $_ and $_ !~ /^(?:extractFormInfo|authenticate)$/ }
              @{ $req->steps };
            $req->steps( \@steps );
            return PE_OK;
        }
    }
    return PE_OK;
}

1;
