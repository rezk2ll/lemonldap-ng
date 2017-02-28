#!/usr/bin/env perl

use Plack::Handler::CGI;
use Lemonldap::NG::Portal::Main;

Plack::Handler::CGI->new->run( Lemonldap::NG::Portal->run( {} ) );

