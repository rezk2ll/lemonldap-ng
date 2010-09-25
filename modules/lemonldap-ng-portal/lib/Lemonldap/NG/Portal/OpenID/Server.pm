package Lemonldap::NG::Portal::OpenID::Server;

use strict;
use fields qw(_extensions setup_url);
use Net::OpenID::Server;

our @ISA     = qw(Net::OpenID::Server);
our $VERSION = '0.1';

sub new {
    my $class = shift;
    my $self  = fields::new($class);
    my %opts  = splice @_;
    $self->$_( delete $opts{$_} ) foreach (qw(extensions));
    $self->SUPER::new(%opts);

    #$self->{get_args} = sub { $self->param(@_) };
}

sub extensions {
    my $self = shift;
    $self->{_extensions} = shift;
}

my $OPENID2_NS        = qq!http://specs.openid.net/auth/2.0!;
my $OPENID2_ID_SELECT = qq!http://specs.openid.net/auth/2.0/identifier_select!;

sub _mode_checkid {
    my Lemonldap::NG::Portal::OpenID::Server $self = shift;
    my ( $mode, $redirect_for_setup ) = @_;

    my $return_to = $self->args("openid.return_to");
    return $self->_fail("no_return_to") unless $return_to =~ m!^https?://!;

    my $trust_root = $self->args("openid.trust_root") || $return_to;
    $trust_root = $self->args("openid.realm")
      if $self->args('openid.ns') eq $OPENID2_NS;
    return $self->_fail("invalid_trust_root")
      unless _url_is_under( $trust_root, $return_to );

    my $identity = $self->args("openid.identity");

 # chop off the query string, in case our trust_root came from the return_to URL
    $trust_root =~ s/\?.*//;

    my $u = $self->_proxy("get_user");
    if (   $self->args('openid.ns') eq $OPENID2_NS
        && $identity eq $OPENID2_ID_SELECT )
    {
        $identity = $self->_proxy( "get_identity", $u, $identity );
    }
    my $is_identity = $self->_proxy( "is_identity", $u, $identity );
    my $is_trusted =
      $self->_proxy( "is_trusted", $u, $trust_root, $is_identity );

    my ( %extVars, %is_ext_trusted );
    my $is_exts_trusted = 1;
    if ( ref( $self->{_extensions} ) ) {
        my @list = $self->get_args->();
        my %extArgs;
        foreach my $arg (@list) {
            print STDERR "ARG: $arg\n";
            next unless ( $arg =~ /^openid\.(\w+)\.([\w\.]+)?/ );
            my $tmp = $1;
            my $val = $2;
            if ( defined $self->{_extensions}->{$tmp} ) {
                $extArgs{$tmp}->{$val} = scalar $self->args->($arg);
            }
        }
        foreach my $ns ( keys %{ $self->{_extensions} } ) {
            my %h;
            ( $is_ext_trusted{$ns}, %h ) =
              $self->{_extensions}->{$ns}
              ->( $u, $is_identity, $is_trusted, $extArgs{$ns} || {} );
            while ( my ( $k, $v ) = each %h ) {
                $extVars{"openid.$ns.$k"} = $v;
            }
            $is_exts_trusted &&= $is_ext_trusted{$ns};
        }
    }

    # assertion path:
    if ( $is_identity && $is_trusted && $is_exts_trusted ) {
        my %sArgs = {
            identity     => $identity,
            claimed_id   => $self->args('openid.claimed_id'),
            return_to    => $return_to,
            assoc_handle => $self->args("openid.assoc_handle"),
            ns           => $self->args('openid.ns'),
        };
        $sArgs{additional_fields} = \%extVars if (%extVars);
        my $ret_url = $self->signed_return_url(%sArgs);
        return ( "redirect", $ret_url );
    }

 # assertion could not be made, so user requires setup (login/trust.. something)
 # two ways that can happen:  caller might have asked us for an immediate return
 # with a setup URL (the default), or explictly said that we're in control of
 # the user-agent's full window, and we can do whatever we want with them now.

    # TODO: call extension sub for setup
    my %setup_args = (
        $self->_setup_map("trust_root"),   $trust_root,
        $self->_setup_map("realm"),        $trust_root,
        $self->_setup_map("return_to"),    $return_to,
        $self->_setup_map("identity"),     $identity,
        $self->_setup_map("assoc_handle"), $self->args("openid.assoc_handle"),
    );
    $setup_args{ $self->_setup_map('ns') } = $self->args('openid.ns')
      if $self->args('openid.ns');

    my $setup_url = $self->{setup_url} or Carp::croak("No setup_url defined.");
    _push_url_arg( \$setup_url, %setup_args );

    if ( $mode eq "checkid_immediate" ) {
        my $ret_url = $return_to;
        if ( $self->args('openid.ns') eq $OPENID2_NS ) {
            _push_url_arg( \$ret_url, "openid.ns",   $self->args('openid.ns') );
            _push_url_arg( \$ret_url, "openid.mode", "setup_needed" );
        }
        else {
            _push_url_arg( \$ret_url, "openid.mode",           "id_res" );
            _push_url_arg( \$ret_url, "openid.user_setup_url", $setup_url );
        }
        return ( "redirect", $ret_url );
    }
    else {

        # the "checkid_setup" mode, where we take control of the user-agent
        # and return to their return_to URL later.

        if ($redirect_for_setup) {
            return ( "redirect", $setup_url );
        }
        else {
            return ( "setup", \%setup_args );
        }
    }
}

#*args = \&get_args;

#sub get_args {
#    my $self = shift;
#
#    if ( my $what = shift ) {
#        Carp::croak("Too many parameters") if @_;
#
#        # Lemonldap::NG only (direct CGI)
#        $self->{get_args} = sub { $what->param( $_[0] ) };
#
#        # INCLUDE IN PROPOSED PATCH FOR Net::OpenID::Server
#        #my $getter;
#        #if ( !ref $what ) {
#        #    Carp::croak("No get_args defined") unless $self->{get_args};
#        #    return $self->{get_args}->($what) || "";
#        #}
#        #elsif ( ref $what eq "HASH" ) {
#        #    $getter = sub { $_[0] ? $what->{ $_[0] } : ( keys %$what ); };
#        #}
#        #elsif ( ref $what eq "Apache" ) {
#        #    my %get = $what->args;
#        #    $getter = sub { $_[0] ? $get{ $_[0] } : ( keys %get ); };
#        #}
#        #elsif ( ref $what eq "CODE" ) {
#        #    $getter = $what;
#        #}
#        #else {
#        #    my $r = eval { $what->can('param') };
#        #    if ( $@ or not $r ) {
#        #        Carp::croak("Unknown parameter type ($what)");
#        #    }
#        #    else {
#        #        $getter = sub {
#        #            $_[0] ? scalar $what->param( $_[0] ) : ( $what->param() );
#        #        };
#        #    }
#        #}
#        #if ($getter) {
#        #    $self->{get_args} = $getter;
#        #}
#    }
#    $self->{get_args};
#}

1;
__END__

=head1 NAME

Lemonldap::NG::Portal::OpenID::Server - Add capability to manage extensions to
Net::OpenID::Server

=head1 SYNOPSIS

  use Lemonldap::NG::Portal::OpenID::Server;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Lemonldap::NG::Portal::OpenID::Server, created by h2xs. It looks like the
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
