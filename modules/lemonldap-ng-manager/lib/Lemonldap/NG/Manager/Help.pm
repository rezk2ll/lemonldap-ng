package Lemonldap::NG::Manager::Help;

use AutoLoader qw(AUTOLOAD);
use UNIVERSAL qw(can);
our $VERSION = '0.1';

sub import {
    my ($caller_package) = caller;
    my $lang = shift;
    $lang = lc($lang);
    foreach ( split( /[,;]/, $lang ) ) {
        next if /=/;
        s/fr-fr/fr/;
        s/en-us/en/;
        if ( __PACKAGE__->can("help_groups_$_") ) {
            $l = $_;
            last;
        }
    }
    $l ||= "en";
    foreach $h (qw(virtualHosts groups ldap vars storage)) {
        *{"${caller_package}::help_$h"} = \&{"help_${h}_$l"};
    }
}

1;
__END__

=pod
=cut
sub help_virtualHosts_en {
    print <<EOT;
<h3>Virtual Hosts</h3>
EOT
}

sub help_groups_en {
    print <<EOT;
<h3>User Groups</h3>
EOT
}

sub help_ldap_en {
    print <<EOT;
<h3>LDAP Parameters</h3>
EOT
}

sub help_vars_en {
    print <<EOT;
<h3>Variables (LDAP attributes)</h3>
EOT
}

sub help_storage_en {
    print <<EOT;
<h3>Sessions Storage</h3>
EOT
}

sub help_virtualHosts_fr {
    print <<EOT;
<h3>H&ocirc;tes virtuels</h3>
EOT
}

sub help_groups_fr {
    print <<EOT;
<h3>Groupes d'utilisateurs</h3>
EOT
}

sub help_ldap_fr {
    print <<EOT;
<h3>Paramètres LDAP</h3>
EOT
}

sub help_vars_fr {
    print <<EOT;
<h3>Variables (attributs LDAP)</h3>
EOT
}

sub help_storage_fr {
    print <<EOT;
<h3>Stockage des sessions</h3>
EOT
}

