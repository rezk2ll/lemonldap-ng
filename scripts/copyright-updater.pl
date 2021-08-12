#!/usr/bin/perl

# Test it:
# $ ./copyright-updater.pl <file>
#
# Run it:
# $ perl -i ./copyright-updater.pl <file>
#
# Copyright (C) 2013, Xavier Guimard, x.guimard@free.fr
#
# This library is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see L<http://www.gnu.org/licenses/>.



use strict;
use utf8;
my ($copy);

binmode( STDOUT, ":utf8" );

# Récupération des données de copyright
{
    local $/ = "\n#";
    while (<DATA>) {
        my ( $name, @tmp, %hash );
        s/^#\s*//;
        s/#$//s;
        /(lemonldap-ng-\S*)/s and $name = $1;
        @tmp = $_ =~ /(20\d+)\s+(\w+)/mg;
        for ( my $i = 0 ; $i <= $#tmp ; $i += 2 ) {

            #
            push @{ $hash{ $tmp[ $i + 1 ] } }, $tmp[$i];
        }
        $copy->{$name} = \%hash;
    }

}

# Constantes
my $authors = {
    guimard       => 'Xavier Guimard, E<lt>x.guimard@free.frE<gt>',
    clement_oudot => 'Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>',
    tchemineau => 'Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>',
    kharec     => 'Sandro Cazzaniga, E<lt>cazzaniga.sandro@gmail.comE<gt>',
    fxdeltombe => 'François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>',
};

# Boucle principale
LOOP: while (<>) {
    my ( $AUTHOR, $COPY );
    unless (/^=head1\s*(AUTHOR|COPYRIGHT|BUG REPORT|DOWNLOAD)/i) {
        print;
        next;
    }
    my $c = $copy->{$ARGV}
      or print STDERR "Manque $ARGV dans les copyrights !\n";
    $AUTHOR =
        "=over\n\n=item "
      . join( "\n\n=item ", map { ( $authors->{$_} ) } sort keys %$c )
      . "\n\n=back";

    $COPY = "=over\n\n=item Copyright (C) "
      . join( "\n\n=item Copyright (C) ",
        map { ( join( ", ", @{ $c->{$_} } ) . " by $authors->{$_}" ) } keys %$c )
      . "\n\n=back";

    print <<"EOC";
=head1 AUTHOR

$AUTHOR

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/issues>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<https://lemonldap-ng.org/download>

=head1 COPYRIGHT AND LICENSE

$COPY

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

EOC
  EFFACE: while (<>) {
        if ( /^=(?:head1|cut)/
            and not /(?:AUTHOR|COPYRIGHT|BUG REPORT|DOWNLOAD)/ )
        {
            print;
            next LOOP;
        }
    }
}

__END__
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Safe.pm
2011 clement_oudot
2011 guimard
2012 clement_oudot
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Regexp.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/CGI/SOAPService.pm
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/CGI/SOAPServer.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf.pm
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2012 kharec
2013 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/BuildWSDL.pm
2009 guimard
2010 clement_oudot
2010 guimard
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Notification/File.pm
2009 guimard
2010 clement_oudot
2011 clement_oudot
2011 guimard
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Notification/DBI.pm
2009 guimard
2010 clement_oudot
2011 clement_oudot
2012 clement_oudot
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Safelib.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Apache/Session/SOAP.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Apache/Session.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2011 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Notification.pm
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2011 guimard
2012 clement_oudot
2012 guimard
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Notification.pm
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2011 guimard
2012 clement_oudot
2012 guimard
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/SOAP.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/LDAP.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/Constants.pm
2008 guimard
2009 clement_oudot
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/File.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/_DBI.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/CDBI.pm
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/RDBI.pm
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/DBI.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/SAML/Metadata.pm
2010 clement_oudot
2010 guimard
2010 tchemineau
2012 clement_oudot
2012 kharec
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/Serializer.pm
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2013 clement_oudot
# lemonldap-ng-common/lib/Lemonldap/NG/Common/Crypto.pm
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
2012 fxdeltombe
# lemonldap-ng-common/lib/Lemonldap/NG/Common/CGI.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2013 fxdeltombe
# lemonldap-ng-common/lib/Lemonldap/NG/Common.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 guimard
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2012 guimard
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/Proxy.pm
2006 clement_oudot
2007 guimard
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/ZimbraPreAuth.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/CDA.pm
2007 guimard
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2012 fxdeltombe
2012 clement_oudot
2012 guimard
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/UpdateCookie.pm
2010 clement_oudot
2010 guimard
2010 tchemineau
2012 clement_oudot
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/Menu.pm
2012 clement_oudot
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/AuthBasic.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2013 fxdeltombe
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/Status.pm
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2012 guimard
2012 kharec
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/Vhost.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2013 clement_oudot
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/SympaAutoLogin.pm
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/Simple.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2013 clement_oudot
2013 fxdeltombe
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/SecureToken.pm
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/CGI.pm
2007 guimard
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 guimard
2012 kharec
# lemonldap-ng-handler/lib/Lemonldap/NG/Handler/SharedConf.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2013 guimard
# lemonldap-ng-handler/example/MyHandlerSecureToken.pm
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-handler/example/MyHandlerLog4Perl.pm
2008 guimard
2009 clement_oudot
2009 guimard
2010 guimard
2012 clement_oudot
# lemonldap-ng-handler/example/MyHandler.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-handler/example/MyHandlerZimbra.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-handler/example/MyHandlerSympa.pm
2010 clement_oudot
2012 clement_oudot
# lemonldap-ng-handler/example/MyUpdateCookieHandler.pm
2010 guimard
2010 tchemineau
2012 clement_oudot
# lemonldap-ng-handler/example/MyHandlerAuthBasic.pm
2012 clement_oudot
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2011 tchemineau
2012 clement_oudot
2012 fxdeltombe
2012 guimard
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Sessions.pm
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2011 tchemineau
2012 clement_oudot
2012 fxdeltombe
2013 guimard
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Uploader.pm
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2013 fxdeltombe
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager/_i18n.pm
2006 guimard
2007 guimard
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2013 clement_oudot
2013 fxdeltombe
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Request.pm
2010 guimard
2010 tchemineau
2012 clement_oudot
2012 fxdeltombe
2012 kharec
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Downloader.pm
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2012 fxdeltombe
2012 clement_oudot
2013 guimard
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager/_Struct.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2012 guimard
2012 kharec
2013 clement_oudot
2013 fxdeltombe
# lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Notifications.pm
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2012 kharec
2013 fxdeltombe
2013 guimard
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/PasswordDBLDAP.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_CAS.pm
2010 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBChoice.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthSlave.pm
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/PasswordDBChoice.pm
2010 clement_oudot
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthChoice.pm
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/IssuerDBCAS.pm
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthTwitter.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthDemo.pm
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBSlave.pm
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_i18n.pm
2007 guimard
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2012 guimard
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthProxy.pm
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/CDC.pm
2010 clement_oudot
2010 guimard
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthApache.pm
2007 guimard
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_SMTP.pm
2009 clement_oudot
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 guimard
2012 kharec
2013 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/CDA.pm
2007 guimard
2008 guimard
2008 tchemineau
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Menu.pm
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
2013 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/PasswordDBDBI.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthYubikey.pm
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBMulti.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthNull.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/OpenID/Server.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/OpenID/SREG.pm
2010 clement_oudot
2010 guimard
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBLDAP.pm
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2009 tchemineau
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 clement_oudot
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_Slave.pm
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_LibAccess.pm
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/PasswordDBNull.pm
2010 clement_oudot
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/PasswordDBDemo.pm
2012 clement_oudot
2012 guimard
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/IssuerDBOpenID.pm
2010 clement_oudot
2010 guimard
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthMulti.pm
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_Proxy.pm
2009 guimard
2010 clement_oudot
2010 guimard
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_Remote.pm
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_SAML.pm
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2011 guimard
2011 tchemineau
2012 fxdeltombe
2012 clement_oudot
2012 guimard
2012 kharec
2013 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBNull.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthRemote.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Simple.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2011 tchemineau
2012 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2012 fxdeltombe
2012 guimard
2012 kharec
2013 clement_oudot
2013 fxdeltombe
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_SOAP.pm
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2013 fxdeltombe
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/IssuerDBNull.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBProxy.pm
2009 guimard
2010 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_DBI.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthSAML.pm
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_LDAP.pm
2008 clement_oudot
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2011 guimard
2012 clement_oudot
2012 fxdeltombe
2012 guimard
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_Choice.pm
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_Multi.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Display.pm
2010 clement_oudot
2010 guimard
2011 clement_oudot
2011 tchemineau
2012 fxdeltombe
2012 clement_oudot
2012 guimard
2012 kharec
2013 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthRadius.pm
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBOpenID.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthCAS.pm
2007 guimard
2008 guimard
2009 clement_oudot
2009 guimard
2009 tchemineau
2010 clement_oudot
2010 guimard
2012 clement_oudot
2013 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/IssuerDBSAML.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
2012 guimard
2013 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthOpenID.pm
2010 clement_oudot
2010 guimard
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBSAML.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2010 tchemineau
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBDemo.pm
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/MailReset.pm
2010 clement_oudot
2010 guimard
2011 clement_oudot
2011 tchemineau
2012 fxdeltombe
2012 clement_oudot
2012 guimard
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthDBI.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBDBI.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthSSL.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2012 clement_oudot
2012 fxdeltombe
2013 fxdeltombe
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/_WebForm.pm
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 guimard
2012 kharec
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/SharedConf.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 guimard
2009 clement_oudot
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 fxdeltombe
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/UserDBRemote.pm
2009 clement_oudot
2009 guimard
2010 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthLDAP.pm
2008 clement_oudot
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
# lemonldap-ng-portal/lib/Lemonldap/NG/Portal.pm
2006 clement_oudot
2006 guimard
2007 guimard
2008 guimard
2009 guimard
2010 clement_oudot
2010 guimard
2011 clement_oudot
2012 clement_oudot
2012 fxdeltombe
