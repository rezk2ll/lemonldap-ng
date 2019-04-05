package Lemonldap::NG::Portal::Lib::_tokenRule;

use strict;
use Mouse;

#use JSON qw(from_json to_json);
#use Crypt::URandom;

our $VERSION = '2.0.3';

#extends 'Lemonldap::NG::Common::Module';

has ottRule => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $rule = $_[0]->conf->{requireToken};
        my $hd   = $_[0]->p->HANDLER;
        $rule = $hd->buildSub( $hd->substitute($rule) );
        unless ($rule) {
            $_[0]->logger->error(
                    'Unable to compile "requireToken" rule, forcing token ('
                  . $hd->tsv->{jail}->error
                  . ')' );
            $rule = sub { 1 };
        }
        return $rule;
    }
);

sub init { 1 }

1;
