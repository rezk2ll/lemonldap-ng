package Lemonldap::NG::Handler::Main::MsgActions;

use strict;
use Exporter 'import';

our @EXPORT = qw(msgActions addAction);

our $msgActions = {
    checkConf => sub {
        my ( $class, $msg, $req ) = @_;
        unless ( $class->checkConf(1) ) {
            $class->logger->error("$class: No configuration found");
            $req->data->{noTry} = 1;
        }
    },
    unlog => sub {
        my ( $class, $msg, $req ) = @_;
        $class->localUnlog( $req, $msg->{id} );
    },
};

sub msgActions { return $msgActions }

sub addAction {
    my ( $name, $sub ) = @_;
    $msgActions->{$name} = $sub;
}

1;
