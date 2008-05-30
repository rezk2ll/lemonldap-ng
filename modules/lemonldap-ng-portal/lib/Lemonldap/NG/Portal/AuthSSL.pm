package Lemonldap::NG::Portal::AuthSSL;

use strict;
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Portal::AuthLDAP;

our @ISA = qw(Lemonldap::NG::Portal::AuthLDAP Lemonldap::NG::Portal::Simple);

our $VERSION = '0.1';

# Authentication is made by Apache with SSL and here before searching the LDAP
# Directory.
# So authenticate is overloaded to return only PE_OK.

# By default, authentication is valid if SSL_CLIENT_S_DN_Email environment
# variable is present. Adapt it if you want
sub authInit {
    my $self = shift;

    # Defaults values
    $self->{SSLRequire} = 1 unless ( defined $self->{SSLRequire} );
    $self->{SSLVar}       ||= 'SSL_CLIENT_S_DN_Email';
    $self->{SSLLDAPField} ||= 'mail';
}

sub extractFormInfo {
    my $self = shift;
    my $user = $self->https ? $ENV{ $self->{SSLVar} } : 0;
    if ($user) {
        $self->{sessionInfo}->{authenticationLevel} = 5;
        $self->{user} = $user;
        return PE_OK;
    }
    elsif ( $self->{SSLRequire} ) {
        return PE_CERTIFICATEREQUIRED;
    }
    return $self->SUPER::extractFormInfo(@_);
}

# As we know only user mail (or SSLVar), we have to use it to find him in
# the LDAP directory
sub formateFilter {
    my $self = shift;
    if (    $self->{sessionInfo}->{authenticationLevel}
        and $self->{sessionInfo}->{authenticationLevel} > 4 )
    {
        $self->{filter} = '(&('
          . $self->{SSLLDAPField} . '='
          . $self->{user}
          . ")(objectClass=person))";
        return PE_OK;
    }
    return $self->SUPER::formateFilter(@_);
}

# Apache SSL environment variable are available in exportedVars:
sub setSessionInfo {
    my $self = shift;
    my $save = $self->{exportedVars};
    if ( ref( $self->{exportedVars} ) eq 'HASH' ) {
        foreach ( keys %{ $self->{exportedVars} } ) {
            if (/^SSL/) {
                $self->{sessionInfo}->{$_} = $ENV{$_};
                delete $self->{exportedVars}->{$_};
            }
        }
    }
    my $r = $self->SUPER::setSessionInfo(@_);
    $self->{exportedVars} = $save;
    return $r;
}

# If authentication has been done with SSL, LDAP bind is disabled
sub authenticate {
    my $self = shift;
    if (    $self->{sessionInfo}->{authenticationLevel}
        and $self->{sessionInfo}->{authenticationLevel} > 4 )
    {
        return PE_OK;
    }
    return $self->SUPER::authenticate(@_);
}

1;
__END__

=head1 NAME

Lemonldap::NG::Portal::AuthSSL - Perl extension for building Lemonldap::NG
compatible portals with SSL authentication.

=head1 SYNOPSIS

With Lemonldap::NG::Portal::SharedConf, set authentication field to "SSL" in
configuration database.

With Lemonldap::NG::Portal::Simple:

  use Lemonldap::NG::Portal::Simple;
  my $portal = new Lemonldap::NG::Portal::Simple(
         domain         => 'example.com',
         globalStorage  => 'Apache::Session::MySQL',
         globalStorageOptions => {
           DataSource   => 'dbi:mysql:database',
           UserName     => 'db_user',
           Password     => 'db_password',
           TableName    => 'sessions',
         },
         ldapServer     => 'ldap.domaine.com',
         securedCookie  => 1,
         authentication => 'SSL',
         
         # SSLVar: field to search in client certificate
         #         default: SSL_CLIENT_S_DN_Email the mail address
         SSLVar         => 'SSL_CLIENT_S_DN_CN',
         
         # SSLLDAPField: field to use in ldap filter to search SSLVar
         #               default: mail
         SSLLDAPField   => 'cn',
         
         # SSLRequire: if set to 1, login/password are disabled
         #             default: 1
         SSLRequire     => 1,
    );

  if($portal->process()) {
    # Write here the menu with CGI methods. This page is displayed ONLY IF
    # the user was not redirected here.
    print $portal->header; # DON'T FORGET THIS (see CGI(3))
    print "...";

    # or redirect the user to the menu
    print $portal->redirect( -uri => 'https://portal/menu');
  }
  else {
    # If the user enters here, IT MEANS THAT YOUR SSL PARAMETERS ARE BAD
    print $portal->header; # DON'T FORGET THIS (see CGI(3))
    print "<html><body><h1>Unable to work</h1>";
    print "This server isn't well configured. Contact your administrator.";
    print "</body></html>";
  }

Modify your httpd.conf:

  <Location /My/File>
    SSLVerifyClient optional # or 'require' if login/password are disabled
    SSLOptions +StdEnvVars
  </Location>

=head1 DESCRIPTION

This library just overload few methods of Lemonldap::NG::Portal::Simple to use
Apache SSLv3 mechanism: we've just to verify that
C<$ENV{SSL_CLIENT_S_DN_Email}> exists. So remenber to export SSL variables
to CGI.

The parameter SSLRequire can be used to authenticate users by SSL or ldap bind.
If SSL is used, authenticationLevel is set to 5. You can use this parameter in
L<Lemonldap::NG::Handler> rules to force users to use certificates in some
applications:

  virtualHost1 => {
    'default' => '$authenticationLevel > 5 and $uid = "jeff"',
  },

Note that you can use Apache SSL environment variables in "exported variables".

See L<Lemonldap::NG::Portal::Simple> for usage and other methods.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Portal::Simple>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2007 by Xavier Guimard E<lt>x.guimard@free.frE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut

