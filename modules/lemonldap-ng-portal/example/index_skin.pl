#!/usr/bin/perl

use Lemonldap::NG::Portal::SharedConf;
use HTML::Template;
use File::Basename;

# Skin configuration
my $skin = "default";
my $skin_dir = "/home/clement/test/lemonldap-ng-0.9/example/portal/skins";

my $portal = Lemonldap::NG::Portal::SharedConf->new(
    {
        configStorage => {
            type    => 'File',
            dirName => '/home/clement/test/lemonldap-ng-0.9/example/conf/',
        },
        formateFilter => sub {
                my $self = shift;
                $self->{filter} = "(&(mail=" . $self->{user} . ")(objectClass=*))";
                PE_OK;
        },
        ldapPpolicyControl => 1,
    }
);

# Template common variables
my $template = HTML::Template->new(filename => "$skin_dir/$skin/index.tpl");
$template->param(AUTH_TITLE => "LemonLDAP::NG Portal");
$template->param(CSS_FILE => "skins/$skin/default.css");

if ( $portal->process() ) {
    print $portal->header;

    # Get sites
    my @sites = ();
    foreach ($portal->getProtectedSites) {
        my %row_data;
        $row_data{SITE_NAME} = $_;
        push (@sites, \%row_data);
    }
    @sites = sort {$a cmp $b} @sites ;
    $template->param(AUTH_SITES => \@sites);
    $template->param(AUTH_ERROR => $portal->error);

    # Logout
    $template->param(LOGOUT_URL => "$ENV{SCRIPT_NAME}?logout=1");

    print $template->output;
} else {
    print $portal->header;
    $template->param(AUTH_ERROR => $portal->error);
    $template->param(AUTH_URL => $portal->param('url'));
    print $template->output;
}

