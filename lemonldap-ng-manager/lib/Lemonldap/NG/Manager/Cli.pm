package Lemonldap::NG::Manager::Cli;

use strict;
use Mouse;
use 5.14.0;
use Data::Dumper;

extends('Lemonldap::NG::Manager::Cli::Lib');

has cfgNum => (
    is      => 'rw',
    isa     => 'Int',
    trigger => sub {
        $_[0]->{req} =
          Lemonldap::NG::Manager::Cli::Request->new(
            cfgNum => $_[0]->{cfgNum} );
    }
);

has sep => ( is => 'rw', isa => 'Str', default => '/' );

has req => ( is => 'ro' );

has format => ( is => 'rw', isa => 'Str', default => "%-25s | %-25s | %-25s" );

has yes => ( is => 'rw', isa => 'Bool', default => 0 );

has force => ( is => 'rw', isa => 'Bool', default => 0 );

sub get {
    my ( $self, @keys ) = @_;
    die 'get requires at least one key' unless (@keys);
  L: foreach my $key (@keys) {
        my $value = $self->_getKey($key);
        if ( ref $value eq 'HASH' ) {
            print "$key has the following keys:\n";
            print "   $_\n" foreach ( sort keys %$value );
        }
        else {
            $value //= '';
            print "$key = $value\n";
        }
    }
}

sub set {
    my ( $self, %pairs ) = @_;
    my $format = $self->format . "\n";
    die 'set requires at least one key and one value' unless (%pairs);
    my @list;
    foreach my $key ( keys %pairs ) {
        my $oldValue = $self->_getKey($key);
        if ( ref $oldValue ) {
            die "$key seems to be a hash, modification refused";
        }
        push @list, [ $key, $oldValue, $pairs{$key} ];
    }
    unless ( $self->yes ) {
        print "Proposed changes:\n";
        printf $format, 'Key', 'Old value', 'New value';
        foreach (@list) {
            printf $format, @$_;
        }
        print "Confirm (N/y)? ";
        my $c = <STDIN>;
        unless ( $c =~ /^y(?:es)?$/ ) {
            die "Aborting";
        }
    }
    require Clone;
    my $new = Clone::clone( $self->mgr->currentConf );
    foreach my $key ( keys %pairs ) {
        $self->_setKey( $new, $key, $pairs{$key} );
    }
    require Lemonldap::NG::Manager::ConfParser;
    my $parser = Lemonldap::NG::Manager::ConfParser->new(
        {
            newConf => $new,
            refConf => $self->mgr->currentConf,
            req     => $self->req
        }
    );
    unless ( $parser->testNewConf() ) {
        printf STDERR "Modifications rejected: %s:\n", $parser->{message};
    }
    my $s = $self->mgr->confAcc->saveConf( $new, { force => $self->force } );
    if ( $s > 0 ) {
        print STDERR "Saved under number $s\n";
    }
    else {
        printf STDERR "Modifications rejected: %s:\n", $parser->{message};
    }
    foreach (qw(errors warnings)) {
        printf STDERR "%-8s: %s", ucfirst($_), Dumper( $parser->{$_} )
          if ( $parser->{$_} and @{ $parser->{$_} } );
    }
}

sub lastCfg {
    my ($self) = @_;
    return $self->jsonResponse('/confs/latest')->{cfgNum};
}

sub _getKey {
    my ( $self, $key ) = @_;
    $self->cfgNum( $self->lastCfg ) unless ( $self->cfgNum );
    my $sep = $self->sep;
    my ( $base, @path ) = split $sep, $key;
    unless ( $base =~ /^\w+$/ ) {
        warn "Malformed key $base";
        return ();
    }
    my $value = $self->mgr->getConfKey( $self->req, $base );
    if ( $self->req->error ) {
        die $self->req->error;
    }
    if ( ref $value eq 'HASH' ) {
        while ( my $next = shift @path ) {
            unless ( exists $value->{$next} ) {
                warn "Unknown subkey $next for $key";
                next L;
            }
            $value = $value->{$next};
        }
    }
    elsif (@path) {
        warn "No subkeys for $base";
        return ();
    }
    return $value;
}

sub _setKey {
    my ( $self, $conf, $key, $value ) = @_;
    my $sep = $self->sep;
    my (@path) = split $sep, $key;
    my $last = pop @path;
    while ( my $next = shift @path ) {
        $conf = $conf->{$next};
    }
    $conf->{$last} = $value;
}

sub run {
    my $self = shift;

    # Options simply call corresponding accessor
    while ( $_[0] =~ s/^--?// ) {
        my $k = shift;
        my $v = shift;
        eval { $self->$k($v) };
        if ($@) {
            die "Unknown option -$k or bad value ($@)";
        }
    }
    unless (@_) {
        die 'nothing to do, aborting';
    }
    my $action = shift;
    unless ( $action =~ /^(?:get|set|addKey|delKey)$/ ) {
        die
"unknown action $action. Only get, set, addKey or delKey are accepted";
    }
    $self->$action(@_);
}

package Lemonldap::NG::Manager::Cli::Request;

use Mouse;

has cfgNum => ( is => 'rw' );

has error => ( is => 'rw' );

sub params {
    my ( $self, $key ) = @_;
    return $self->{$key};
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Manager::Cli - Command line manager for Lemonldap::NG web SSO
system.

=head1 SYNOPSIS

  #!/usr/bin/env perl
  
  use warnings;
  use strict;
  use Lemonldap::NG::Manager::Cli;
  
  # Optional: you can specify here some parameters
  my $cli = Lemonldap::NG::Manager::Cli->new(iniFile=>'t/lemonldap-ng.ini');
  
  $cli->run(@ARGV);

or use llng-manager-cli provides with this package.

  llng-manager-cli <options> <command> <keys>

=head1 DESCRIPTION

Lemonldap::NG::Manager provides a web interface to manage Lemonldap::NG Web-SSO
system.

Lemonldap::NG Manager::Cli provides a command line client to read or modify
configuration.

=head1 METHODS

=head2 ACCESSORS

All accessors can be set using the command line: just set a '-' before their
names. Example

  llng-manager-cli -sep ',' get macros,_whatToTrace

=head3 iniFile()

The lemonldap-ng.ini file to use is not default value.

=head3 sep()

The key separator, default to '/'. For example to read the value of macro
_whatToTrace using ',', use:

  llng-manager-cli -sep ',' get macros,_whatToTrace

=head3 cfgNum()

The configuration number. If not set, it will use the latest configuration.

=head3 yes()

If set to 1, no confirmation is asked to save new values:

  llng-manager -yes 1 set portal http://somewhere/

=head3 force()

Set it to 1 to save a configuration earlier than latest

=head3 format()

Confirmation array line format. Default to "%-25s | %-25s | %-25s"

=head2 run()

The main method: it reads option, command and launch the corresponding
subroutine.

=head3 Commands

=head4 get

Using get, you can read several keys. Example:

  llng-manager-cli get portal cookieName domain

=head1 SEE ALSO

L<Lemonldap::NG::Manager>, L<http://lemonldap-ng.org/>

=head1 AUTHORS

Original idea from David Delassus in 2012.

=over

=item Clement Oudot, E<lt>clem.oudot@gmail.comE<gt>

=item David Delassus, E<lt>linkdd@cpan.orgE<gt>

=item François-Xavier Deltombe, E<lt>fxdeltombe@gmail.com.E<gt>

=item Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Thomas Chemineau, E<lt>thomas.chemineau@gmail.comE<gt>

=back

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://jira.ow2.org>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

=over

=item Copyright (C) 2015 by Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=item Copyright (C) 2015 by Clément Oudot, E<lt>clem.oudot@gmail.comE<gt>

=back

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

=cut
