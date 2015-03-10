#######################################################
#
# Lemonldap::NG::Common::Apache::Session::Serialize::JSON
# Serializes session objects using JSON
# Copyright(c) 2015 Xavier Guimard (x.guimard@free.fr)
# Distribute under the GPL2 License
#
#######################################################

package Lemonldap::NG::Common::Apache::Session::Serialize::JSON;

use strict;
use vars qw($VERSION);
use JSON;

our $VERSION = '1.5.99';

sub serialize {
    my $session = shift;

    $session->{serialized} = encode_json( $session->{data} );
}

sub unserialize {
    my $session = shift;

    my $data = decode_json( $session->{serialized} );
    die "Session could not be unserialized" unless defined $data;
    $session->{data} = $data;
}

1;

=pod

=head1 NAME

Lemonldap::NG::Common::Apache::Session::Serialize::JSON - Use JSON to zip up data

=head1 SYNOPSIS

 use Lemonldap::NG::Common::Apache::Session::Serialize::JSON;

 $zipped = Lemonldap::NG::Common::Apache::Session::Serialize::JSON::serialize($ref);
 $ref = Lemonldap::NG::Common::Apache::Session::Serialize::JSON::unserialize($zipped);

=head1 DESCRIPTION

This module fulfills the serialization interface of Apache::Session.
It serializes the data in the session object by use of JSON C<encode_json>
and C<decode_json>. The serialized data is UTF-8 text.

=head1 AUTHOR

This module was written by Xavier Guimard <x.guimard@free.fr> using other
Apache::Session serializer written by Jeffrey William Baker <jwbaker@acm.org>.

=head1 SEE ALSO

L<JSON>, L<Apache::Session>
