package Lemonldap::NG::Common::OpenID::Server;

use strict;
use fields qw(_extensions);
use Net::OpenID::Server;

our @ISA     = qw(Net::OpenID::Server);
our $VERSION = '0.1';

sub new {
    my $class = shift;
    my $self  = fields::new($class);
    my %opts  = splice @_;
    $self->$_( delete $opts{$_} ) foreach (qw(extensions));
    return $self->SUPER::new(%opts);
}

sub extensions {
    my $self = shift;
    $self->{_extensions} = @_;
}

sub signed_return_url {
    my ( $self, %opts ) = splice @_;
    my $extra;
    if ( ref $self->{_extensions} ) {
        my $list = $self->args();
        my @list = $self->get_args();
        my %h;
        foreach my $arg (@list) {
            next unless ( $arg =~ /^openid\.(\w+)(\.[\w\.]+)?/ );
            my $tmp = $1;
            my $val = $2;
            if ( defined $self->{_extensions}->{$tmp} ) {
                push @{ $h{$tmp} }, $val, scalar self->get_args($arg);
            }
        }
        my %vars;
        foreach my $ns ( keys %h ) {
            my %h = $self->{_extensions}->{$ns}->( @{ $h{$ns} } );
            while ( my ( $k, $v ) = each %h ) {
                $vars{"openid.$ns.$k"} = $v;
            }
        }
        $opts{extra_fields} = \%vars;
    }
    return $self->SUPER::signed_return_url(%opts);
}

*args = \&get_args;

sub get_args {
    my $self = shift;

    if ( my $what = shift ) {
        Carp::croak("Too many parameters") if @_;

        # Lemonldap::NG only (direct CGI)
        $self->{get_args} = sub { $what->param( $_[0] ) };

        # INCLUDE IN PROPOSED PATCH FOR Net::OpenID::Server
        #my $getter;
        #if ( !ref $what ) {
        #    Carp::croak("No get_args defined") unless $self->{get_args};
        #    return $self->{get_args}->($what) || "";
        #}
        #elsif ( ref $what eq "HASH" ) {
        #    $getter = sub { $_[0] ? $what->{ $_[0] } : ( keys %$what ); };
        #}
        #elsif ( ref $what eq "Apache" ) {
        #    my %get = $what->args;
        #    $getter = sub { $_[0] ? $get{ $_[0] } : ( keys %get ); };
        #}
        #elsif ( ref $what eq "CODE" ) {
        #    $getter = $what;
        #}
        #else {
        #    my $r = eval { $what->can('param') };
        #    if ( $@ or not $r ) {
        #        Carp::croak("Unknown parameter type ($what)");
        #    }
        #    else {
        #        $getter = sub {
        #            $_[0] ? scalar $what->param( $_[0] ) : ( $what->param() );
        #        };
        #    }
        #}
        #if ($getter) {
        #    $self->{get_args} = $getter;
        #}
    }
    $self->{get_args};
}

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
