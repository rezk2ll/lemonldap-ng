package Lemonldap::NG::Handler::Status;

use strict;

our $status   = {};
our $activity = [];
our $start    = int( time / 60 );
use constant MN_COUNT => 10;

sub run {
    my ( $localStorage, $localStorageOptions ) = ( shift, shift );
    my $refLocalStorage;
    eval
"use $localStorage; \$refLocalStorage = new $localStorage(\$localStorageOptions);";
    die($@) if ($@);
    $| = 1;
    my ( $lastMn, $mn );
    while (<STDIN>) {
        $mn = int( time / 60 ) - $start;

        # Cleaning activity array
        if ( $mn > $lastMn ) {
            for ( my $i = 0 ; $i < $mn - $lastMn ; $i++ ) {
                unshift @$activity, {};
                delete $activity->[MN_COUNT];
            }
        }
        $lastMn = $mn;

        # Activity collect
        if (/^(\S+)\s+=>\s+(\S+)\s+(OK|REJECT|REDIRECT|LOGOUT)$/) {
            my ( $user, $uri, $code ) = ( $1, $2, $3 );

            # Per user activity
            $status->{user}->{$user}->{$code}++;

            # Per uri activity
            $uri =~ s/^(.*?)\?.*$/$1/;
            $status->{uri}->{$uri}->{$code}++;

            # Last 5 minutes activity
            $activity->[0]->{$code}++;
        }

        # Status requests

        # $args conatins parameters passed to url status page (a=1 for example
        # if request is http://test.example.com/status?a=1). To be used
        # later...
        elsif (/^STATUS(?:\s+(\S+))?$/) {
            my $args = $1;
            my ( $c, $a, $u );
            while ( my ( $user, $v ) = each( %{ $status->{user} } ) ) {
                $u++;
                # Total requests
                foreach ( keys %$v ) {
                    $c->{$_} += $v->{$_};
                }
            }
            foreach my $mn (@$activity) {
                $a->{$_} += $mn->{$_} foreach ( keys %$mn );
            }
            foreach ( keys %$a ) {
                $a->{$_} = sprintf( "%.2f", $a->{$_} / MN_COUNT );
                $a->{$_} = int( $a->{$_} ) if ( $a->{$_} > 99 );
            }

            # DEVEL
            #use Data::Dumper;
            #print Dumper( $c, $a, $status );
            my @t =
              $refLocalStorage->get_keys( $localStorageOptions->{namespace} );
            print "TOTAL\n";
            print sprintf("%-10s : %d\n", $_, $c->{$_}) foreach(sort keys %$c);
            print "\nAVERAGE\n";
            print sprintf("%-10s : %s\n", $_, $a->{$_}) foreach(sort keys %$a);
            print "\nUsers : $u\n\nLocal Cache : " . @t . " objects\n";
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
