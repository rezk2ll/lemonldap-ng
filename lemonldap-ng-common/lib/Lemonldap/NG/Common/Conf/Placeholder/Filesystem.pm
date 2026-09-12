##@file
# Configuration placeholder reading secrets in local files

##@class
# Implements the %FILE:name% configuration placeholder. It is declared by the
# "configPlaceHolderModules" ini parameter and configured by the
# "filesystemPlaceholderDirectory" one, see
# doc/sources/admin/filesystemplaceholder.rst
package Lemonldap::NG::Common::Conf::Placeholder::Filesystem;

use strict;
use Encode ();

our $VERSION = '3.0.0';

# A name is made of "/" separated segments, each starting with a letter, a
# digit or "_": ".." segments, absolute paths and hidden files are refused, so
# the configuration can not designate a file outside of the directory
my $segment = qr/[A-Za-z0-9_][A-Za-z0-9_.-]*/;

## @cmethod string replace(hashRef conf, string variable)
# Return the content of the file designated by $variable, without leading and
# trailing spaces. Dies if the name is refused, or if the file is missing,
# unreadable, empty or not UTF-8 encoded: the caller then rejects the whole
# configuration.
# @param $conf Lemonldap::NG::Common::Conf object
# @param $variable content of the %FILE:...% placeholder
# @return file content
sub replace {
    my ( $class, $conf, $variable ) = @_;
    my $file = _path( $conf, $variable );

    die "Filesystem: '$file' is not a regular file\n"
      if ( -e $file and !-f _ );

    # Read at each call: a mounted secret is rotated in place
    open my $fh, '<:raw', $file
      or die "Filesystem: unable to read '$file': $!\n";
    my $content = do { local $/; <$fh> };
    close $fh;

    # The content is never displayed in error messages
    $content = eval {
        Encode::decode(
            'UTF-8',
            $content // '',
            Encode::FB_CROAK | Encode::LEAVE_SRC
        );
    };
    die "Filesystem: '$file' is not a valid UTF-8 file\n"
      unless defined $content;
    $content =~ s/^\s+|\s+$//g;
    die "Filesystem: '$file' is empty\n" unless length $content;
    return $content;
}

## @fn private string _path(hashRef conf, string variable)
# Check the name of the file and build its path
# @param $conf Lemonldap::NG::Common::Conf object
# @param $variable content of the %FILE:...% placeholder
# @return path of the file
sub _path {
    my ( $conf, $variable ) = @_;
    my $dir =
      $conf->{filesystemPlaceholderDirectory} || $ENV{CREDENTIALS_DIRECTORY}
      or die "Filesystem: missing 'filesystemPlaceholderDirectory' option"
      . " (or CREDENTIALS_DIRECTORY environment variable)\n";
    die "Filesystem: directory '$dir' does not exist\n" unless -d $dir;
    $dir =~ s{/+$}{};

    my $name = defined $variable ? $variable : '';
    $name =~ s/^\s+|\s+$//g;
    die "Filesystem: bad file name '$name'\n"
      unless $name =~ m{^$segment(?:/$segment)*\z};
    return "$dir/$name";
}

1;
