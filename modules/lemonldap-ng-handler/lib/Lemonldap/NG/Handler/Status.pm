package Lemonldap::NG::Handler::Status;

use strict;

our $status = {};

sub run {
    my ( $localStorage, $localStorageOptions ) = ( shift, shift );
    my $refLocalStorage;
    eval "use $localStorage; \$refLocalStorage = new $localStorage(\$localStorageOptions);";
    die($@) if ($@);
    $| = 1;
    while (<STDIN>) {
        if (/^(\S+)\s+=>\s+(\S+)\s+(OK|REJECT|REDIRECT|LOGOUT)$/) {
            my ( $user, $uri, $code ) = ( $1, $2, $3 );
            $status->{user}->{$user}->{$code}++;
            $uri =~ s/^(.*?)\?.*$/$1/;
            $status->{uri}->{$uri}->{$code}++;
        }
        elsif (/^STATUS$/) {
            my $c;
            while ( my ( $user, $v ) = each( %{ $status->{user} } ) ) {
                foreach ( keys %$v ) {
                    $c->{$_} += $v->{$_};
                }
            }
            # DEVEL
            use Data::Dumper;
            print Dumper($c);
            my @t = $refLocalStorage->get_keys( $localStorageOptions->{namespace} );
            print "Local Cache : " . @t . " objects\n";
            print "END\n";
        }
    }
}
1;
__END__

=head1 NAME

Lemonldap::NG::Handler::Status - Perl extension to add a mod_status like system for L<Lemonldap::NG::Handler>

=head1 SYNOPSIS

=head2 Create your Apache module

Create your own package (example using a central configuration database):

  package My::Package;
  use Lemonldap::NG::Handler::SharedConf;
  @ISA = qw(Lemonldap::NG::Handler::SharedConf);
  
  __PACKAGE__->init ( {
    # Activate status feature
    status              => 1,
    # Local storage used for sessions and configuration
    localStorage        => "Cache::DBFile",
    localStorageOptions => {...},
    # How to get my configuration
    configStorage       => {
        type                => "DBI",
        dbiChain            => "DBI:mysql:database=lemondb;host=$hostname",
        dbiUser             => "lemonldap",
        dbiPassword          => "password",
    }
    # ... See Lemonldap::N::Handler
  } );

=head2 Configure Apache

Call your package in /apache-dir/conf/httpd.conf:

  # Load your package
  PerlRequire /My/File
  # Normal Protection
  PerlHeaderParserHandler My::Package
  
  # Status page
  <Location /status>
    Order deny,allow
    Allow from 10.1.1.0/24
    Deny from all
    PerlHeaderParserHandler My::Package->status
  </Location>

=head1 DESCRIPTION

Lemonldap::NG::Handler::Status adds a mod_status like feature to display
Lemonldap::NG::Handler activity on a protected server. It can so be used by
L<mrtg> or directly browsed by your browser.

=head1 SEE ALSO

L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Manager>,
L<http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation>

=head1 AUTHOR

Xavier Guimard, E<lt>guimard@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
