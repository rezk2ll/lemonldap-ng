package Lemonldap::NG::Common::OpenID::Server;

use strict;
use fields qw(_extensions);
use Net::OpenID::Server;

our @ISA = qw(Net::OpenID::Server);
our $VERSION = '0.1';

sub new {
    my $class = shift;
    my $self = fields::new($class);
    my %opts = splice @_;
    $self->$_(delete $opts{$_}) foreach (qw(extensions));
    return $self->SUPER::new(%opts);
}

sub extensions {
    my $self = shift;
    $self->{_extensions} = @_;
}

sub signed_return_url {
    my ( $self, %opts ) = splice @_;
    my $extra;
    if(ref $self->{_extensions}){
        my $list = $self->args();
        my @list = $self->get_args();
        my %h;
        foreach my $arg (@list) {
            next unless($arg =~/^openid\.(\w+)/);
            my $tmp = $1;
            if(defined $self->{_extensions}->{$tmp}) {
                push @{$h{$tmp}},$arg,scalar self->get_args($arg);
            }
        }
        my %vars;
        foreach my $ns (keys %h){
            %vars = (%vars,$self->{_extensions}->{$ns}->(@{$h{$ns}}));
        }
        $opts{extra_fields} = \%vars;
    }
    return $self->SUPER::signed_return_url(%opts);
}

#sub get_args {
#    my ($self, $hash) = shift;
#    return sub
#}

1;
__END__

=head1 NAME

Lemonldap::NG::Common::OpenID::Server - Add capability to manage extensions to
Net::OpenID::Server

=head1 SYNOPSIS

  use Lemonldap::NG::Common::OpenID::Server;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Lemonldap::NG::Common::OpenID::Server, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

guimard, E<lt>guimard@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
