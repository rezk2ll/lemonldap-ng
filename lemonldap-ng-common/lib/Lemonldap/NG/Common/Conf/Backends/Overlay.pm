##@file
# Removed in 3.0, see doc/sources/admin/overlayconfbackend.rst
package Lemonldap::NG::Common::Conf::Backends::Overlay;

use strict;

our $VERSION = '3.0.0';

die 'the "Overlay" configuration backend has been removed in 3.0.'
  . ' In lemonldap-ng.ini, replace "type = Overlay" and "overlayRealtype = X"'
  . ' by "type = X" (the options of the real backend are unchanged), and'
  . ' "overlayDirectory = D" by "configPlaceHolderModules ='
  . ' FILE=Lemonldap::NG::Common::Conf::Placeholder::Filesystem" and'
  . ' "filesystemPlaceholderDirectory = D". Then give to each formerly'
  . ' overlayed parameter P the value "%FILE:P%" in the configuration.'
  . ' "overlayWrite" has no equivalent: the Manager no longer writes secrets'
  . ' on disk, this is deliberate. See'
  . " https://lemonldap-ng.org/documentation/latest/overlayconfbackend.html\n";
