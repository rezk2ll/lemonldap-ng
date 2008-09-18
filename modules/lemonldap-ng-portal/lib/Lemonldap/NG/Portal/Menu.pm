package Lemonldap::NG::Portal::Menu;

use strict;
use warnings;
use Exporter 'import';
use Lemonldap::NG::Portal::Simple;
use Lemonldap::NG::Handler::Simple;
use XML::LibXML;

our $VERSION = '0.01';

our @ISA = qw(Exporter);

my $catlevel = 0;

# CONSTRUCTOR
sub new {
    my $class = shift;
    my $self  = {};
    bless($self,$class);

    # Get configuration
    $self->Lemonldap::NG::Portal::Simple::getConf(@_) or die "Unable to get configuration";
    
    # Portal is required
    die("Portal object required") unless ( $self->{portalobject} );

    # Default values
    $self->{apps}->{xmlfile} ||= 'apps-list.xml';
    $self->{apps}->{imgpath} ||= 'apps/';
    $self->{modules}->{appslist}= 0 unless defined $self->{modules}->{appslist};
    $self->{modules}->{password}= 0 unless defined $self->{modules}->{password};
    $self->{modules}->{logout}= 1 unless defined $self->{modules}->{logout};

    # Get the error of the portal
    $self->{error} = $self->{portal}->{error};

    # TODO: display ppolicy message get in portal LDAP authentication 
    # if $self->{portal}->{ppolicy} ...

    # Change password if 'newpassword" submitted
    if (defined $self->{portalobject}->{newpassord}) {
        $self->{error} = $self->_changePassword;
    }

    return $self;
}

sub error {
    # Copied from Simple.pm
    # TODO: reuse Simple.pm function
    my $self = shift;
    return &Lemonldap::NG::Portal::_i18n::error( $self->{error},
        shift || $ENV{HTTP_ACCEPT_LANGUAGE} );
}

sub error_type {
    my $self = shift;
    # TODO: use Simple.pm function
    #return $self->Lemonldap::NG::Portal::Simple::error_type;
    return "positive";
}

# displayModule($modulename)
# Return true if the user can see the module
# Use for HTML::Template variable
sub displayModule() {
    my $self = shift;
    my ($modulename) = @_;

    # TODO: use rules to display modules (like $groups =~ /\badmin\b/)
    return 1 if (
        (($modulename eq "appslist") and $self->{modules}->{appslist})
     or (($modulename eq "password") and $self->{modules}->{password})
     or (($modulename eq "logout")   and $self->{modules}->{logout}  )
    );
    
    return 0;
}

# appslistDiv
# Div containing application menu and description
sub appslistDiv {
    my $self = shift;
    my $html;

    # Parse XML file
    my $parser = XML::LibXML->new();
    $parser->validation('1');
    my $xml = $parser->parse_file($self->{apps}->{xmlfile});
    my $root = $xml->documentElement;

    # Filter XML file with user's authorizations
    $self->_filterXML($root);

    # Display all categories and applications
    $html .= "<div id=\"appslist\">\n";
    $html .= $self->_displayCategory($root,$catlevel);
    $html .= "</div>\n";
    # Display application description
    $html .= $self->_displayDescription($root);

    return $html;
}

# _displayCategory
# Create HTML code for a category
sub _displayCategory() {
    my $self = shift;
    my ($cat, $catlevel) = @_;
    my $html;
    my $catname;

    # Category name
    if ($catlevel > 0) { $catname = $cat->getAttribute('name') || " "; }
    else { $catname = "Menu"; }

    # Init HTML list
    $html .= "<ul class=\"category cat-level-$catlevel\">\n";
    $html .= "<span>$catname</span>\n";

    # Display applications first
    my @appnodes = $cat->findnodes("application");
    foreach (@appnodes) {
        $html .= $self->_displayApplication($_);
    }

    # Display subcategories
    my @catnodes = $cat->findnodes("category");
    $catlevel++;
    foreach (@catnodes) {
        $html .= $self->_displayCategory($_,$catlevel);
    }

    # Close HTML list
    $html .= "</ul>\n";

    return $html;
}

# _displayApplication
# Create HTML code for an application
sub _displayApplication() {
    my $self = shift;
    my ($app) = @_;
    my $html;
    
    # Get application items
    my $appid = $app->getAttribute('id');
    my $appname = $app->getElementsByTagName('name')->string_value() || $appid;
    my $appuri = $app->getElementsByTagName('uri')->string_value() || "#";

    # Display application
    $html .= "<li name=\"$appid\"><a href=\"$appuri\"><span>$appname</span><a></li>\n";

    return $html;
}


# _displayDescription
# Create HTML code for application description
sub _displayDescription {
    my $self = shift;
    my ($root) = @_;
    my $html;

    my @apps = $root->getElementsByTagName('application');
    foreach (@apps) {
        # Get application items
        my $appid = $_->getAttribute('id');
        my $appname = $_->getElementsByTagName('name')->string_value();
        my $appuri = $_->getElementsByTagName('uri')->string_value() || "#";
        my $appdesc = $_->getElementsByTagName('description')->string_value();
        my $applogofile = $_->getElementsByTagName('logo')->string_value();
        my $applogo = $self->{apps}->{imgpath}.$applogofile;

	# Display application
        $html .= "<div id=\"$appid\" class=\"appsdesc\">\n";
        $html .= "<a href=\"$appuri\"><img src=\"$applogo\" alt=\"$appid logo\" /></a>\n" if defined $applogofile;
        $html .= "<p class=\"appname\">$appname</p>\n" if defined $appname;
        $html .= "<p class=\"appdesc\">$appdesc</p>\n" if defined $appdesc;
        $html .= "</div>\n";
    }

    return $html;
}

# _filterXML
# Remove unauthorized nodes 
sub _filterXML {
    my $self = shift;
    my ($root) = @_;

    my @apps = $root->getElementsByTagName('application');
    foreach (@apps) {
        my $appdisplay = $_->getElementsByTagName('display')->string_value();
        my $appuri = $_->getElementsByTagName('uri')->string_value();
	
	# Remove node if display is "no"
	$_->unbindNode if ($appdisplay eq "no");

	# Keep node if display is "yes"
	next if ($appdisplay eq "yes");
	
	# Check grant function if display is "auto" (this is the default)
	$_->unbindNode unless ($self->_grant($appuri));
	
    }

    # Hide empty categories
    $self->_hideEmptyCategory($root);

    return;
}

# _hideEmptyCategory
# 
sub _hideEmptyCategory {
    my $self = shift;
    my ($cat) = @_;

    # Check subnodes
    my @catnodes = $cat->findnodes("category");
    my @appnodes = $cat->findnodes("application");

    # Check each subcategory
    foreach (@catnodes) {
        $self->_hideEmptyCategory($_);
    }

    # Update node list
    @catnodes = $cat->findnodes("category");

    # Remove the node if it contains no category or no application
    unless ( scalar(@catnodes) || scalar(@appnodes) ) {
        $cat->unbindNode;
        return;
    }

    return;
}

# _grant
# Check user's authorization
sub _grant {
    my $self = shift;
    my ($uri) = @_;

    # TODO: implement grant function to behave like the Handler one

    return 1;
}

# _changePassword
# Change user's password
sub _changePassword {
    my $self = shift;
    
    # TODO: get the submitted password
    # TODO: use portal LDAP connect function
    # TODO: LDAP modify, with or without ppolicy

    return PE_OK;
}

1;

__END__

=head1 NAME

Lemonldap::NG::Portal::Menu - Enhanced menu to display to authenticated users

=head1 SYNOPSIS

    use Lemonldap::NG::Portal::Menu;
    my $menu = Lemonldap::NG::Portal::Menu->new(
      {
        portalobject => $portal,
        apps => {
            xmlfile => "/var/lib/lemonldap-ng/conf/apps-list.xml",
            imgpath => "apps/",
        },
        modules => {
            appslist => 1,
            password => 1,
            logout => 1,
        },
      }
    );

    # Print HTML code of authorized applications list
    print $menu->apsslistDiv;

=head1 DESCRIPTION

Lemonldap::NG::Portal::Menu provides these web modules:

=over

=item * Application list: display a full menu with all authorized applications

=item * Password: allow the user to change its password (with LDAP auth only)

=item * Logout: display a simple logout confirmation page

=back

These web modules are designed to be used in HTML::Template, with the help of 
Jquery scripts. Without that, this will only output raw HTML code.

=head1 SEE ALSO

L<Lemonldap::NG::Portal>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/EnhancedMenu
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Clement OUDOT E<lt>clem.oudot@gmail.comE<gt>

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


