##@file
# Menu for Lemonldap::NG portal

##@class
# Menu class for Lemonldap::NG portal
package Lemonldap::NG::Portal::Menu;

use strict;
use warnings;
require Lemonldap::NG::Common::CGI;
use Lemonldap::NG::Portal::SharedConf;
use Lemonldap::NG::Common::Safelib;    #link protected safe Safe object
use Safe;
use constant SAFEWRAP => ( Safe->can("wrap_code_re") ? 1 : 0 );

#inherits Net::LDAP::Control::PasswordPolicy

our $VERSION = '0.3';

### ACCESS CONTROL DISPLAY SYSTEM

our ( $defaultCondition, $locationCondition, $locationRegexp, $cfgNum, $path ) =
  ( undef, undef, undef, 0 );

## @method private Safe _safe()
# Build and returns security jail.
# Includes custom functions
# @return Safe object
sub _safe {
    my $self = shift;
    return $self->{_safe} if ( $self->{_safe} );
    $self->{_safe} = new Safe;
    $self->{customFunctions} ||= $self->{portalObject}->{customFunctions};
    my @t =
      $self->{customFunctions} ? split( /\s+/, $self->{customFunctions} ) : ();
    foreach (@t) {
        my $sub = $_;
        unless (/::/) {
            $sub = "$self->{caller}::$_";
        }
        else {
            s/^.*:://;
        }
        next if ( __PACKAGE__->can($_) );
        eval "sub $_ {
            return $sub(\$path,\@_);
        }";
        $self->{portalObject}->lmLog( $@, 'error' ) if ($@);
    }
    $self->{_safe}->share_from( 'main', ['%ENV'] );
    $self->{_safe}->share_from( 'Lemonldap::NG::Common::Safelib',
        $Lemonldap::NG::Common::Safelib::functions );
    $self->{_safe}->share( '&encode_base64', @t );
    return $self->{_safe};
}

my $catlevel = 0;

##@cmethod Lemonldap::NG::Portal::Menu new(hashRef args)
# Constructor.
# $args->{portalObject} is required.
#@param $args hash reference
#@return new object
sub new {
    my $class = shift;
    my $self  = {};
    bless( $self, $class );

    # Get configuration
    $self->Lemonldap::NG::Portal::Simple::getConf(@_)
      or Lemonldap::NG::Common::CGI->abort(
        "Unable to read $class->new() parameters");

    # Portal is required
    Lemonldap::NG::Common::CGI->abort("Portal object required")
      unless ( $self->{portalObject} );

    # Fill sessionInfo (yet done in portal...)
    #&Lemonldap::NG::Portal::Simple::getSessionInfo( $self->{portalObject} );

    # Default values
    $self->{apps}->{imgpath} ||= '/apps/';
    $self->{modules}->{appslist} = 0
      unless defined $self->{modules}->{appslist};
    $self->{modules}->{password} = 0
      unless defined $self->{modules}->{password};
    $self->{modules}->{logout} = 1 unless defined $self->{modules}->{logout};
    $self->{'caller'} = caller;

    # Store POST data in $self->{portalObject}
    $self->{portalObject}->{'newpassword'} =
      $self->{portalObject}->param('newpassword');
    $self->{portalObject}->{'confirmpassword'} =
      $self->{portalObject}->param('confirmpassword');
    $self->{portalObject}->{'oldpassword'} =
      $self->{portalObject}->param('oldpassword');
    $self->{portalObject}->{'dn'} =
      $self->{portalObject}->{sessionInfo}->{'dn'};
    $self->{portalObject}->{'user'} =
      $self->{portalObject}->{sessionInfo}->{'_user'};

# Password modification functions (TODO merge Menu.pm in Simple.pm to inherits those functions)
# Default to LDAP
    $self->{portalObject}->{passwordDB} ||= 'LDAP';
    if ( $self->{portalObject}->{passwordDB} =~ /DBI/i ) {
        use Lemonldap::NG::Portal::PasswordDBDBI;    #inherits
        use Lemonldap::NG::Portal::_DBI
          ;    #link protected dbi Object used to change passwords only
        *_modifyPassword =
          *Lemonldap::NG::Portal::PasswordDBDBI::modifyPassword;
        *_passwordDBInit =
          *Lemonldap::NG::Portal::PasswordDBDBI::passwordDBInit;
    }
    if ( $self->{portalObject}->{passwordDB} =~ /Null/i ) {
        use Lemonldap::NG::Portal::PasswordDBNull;    #inherits
        *_modifyPassword =
          *Lemonldap::NG::Portal::PasswordDBNull::modifyPassword;
        *_passwordDBInit =
          *Lemonldap::NG::Portal::PasswordDBNull::passwordDBInit;
    }
    if ( $self->{portalObject}->{passwordDB} =~ /LDAP/i ) {
        use Lemonldap::NG::Portal::PasswordDBLDAP;    #inherits
        use Lemonldap::NG::Portal::_LDAP
          'ldap';    #link protected ldap Object used to change passwords only
        *_modifyPassword =
          *Lemonldap::NG::Portal::PasswordDBLDAP::modifyPassword;
        *_passwordDBInit =
          *Lemonldap::NG::Portal::PasswordDBLDAP::passwordDBInit;
    }

    # Change password (only if newpassword submitted)
    $self->{portalObject}->{error} = &_passwordDBInit( $self->{portalObject} )
      if $self->{portalObject}->{'newpassword'};
    $self->{portalObject}->{error} = &_modifyPassword( $self->{portalObject} )
      if $self->{portalObject}->{'newpassword'};

    return $self;
}

## @method boolean displayModule(string modulename)
# Return true if the user can see the module.
# Use for HTML::Template variable.
# @param $modulename string
# @return boolean
sub displayModule {
    my ( $self, $modulename ) = splice @_;

    # Manage "0" and "1" rules
    return 1 if ( $self->{modules}->{$modulename} eq "1" );
    return 0 if ( $self->{modules}->{$modulename} eq "0" );

    # Else parse display condition
    my $cond = $self->{modules}->{$modulename};
    $cond =~ s/\$(\w+)/$self->{portalObject}->{sessionInfo}->{$1}/g;
    return (
        SAFEWRAP
        ? $self->_safe->wrap_code_ref(
            $self->_safe->reval("sub{return($cond)}")
          )
        : $self->_safe->reval("sub{return($cond)}")
    );
}

## @method string displayTab()
# Tells which tab should be selected.
# Design for Jquery tabs.
# @return password, appslist or logout
sub displayTab {
    my $self = shift;

    # Display password tab if password change is needed or failed
    return "password"
      if (
        (
            scalar(
                grep { $_ == $self->{portalObject}->{error} } (
                    25,    #PE_PP_CHANGE_AFTER_RESET
                    27,    #PE_PP_MUST_SUPPLY_OLD_PASSWORD
                    28,    #PE_PP_INSUFFICIENT_PASSWORD_QUALITY
                    29,    #PE_PP_PASSWORD_TOO_SHORT
                    30,    #PE_PP_PASSWORD_TOO_YOUNG
                    31,    #PE_PP_PASSWORD_IN_HISTORY
                    32,    #PE_PP_GRACE
                    33,    #PE_PP_EXP_WARNING
                    34,    #PE_PASSWORD_MISMATCH
                    39,    #PE_BADOLDPASSWORD
                )
            )
        )
        && $self->displayModule("password")
      );

    return "appslist" if ( $self->displayModule("appslist") );
    return "logout";
}

## @method string appslistMenu()
# Returns HTML code for application list menu.
# @return HTML string
sub appslistMenu {
    my $self = shift;

    # We no more use XML file for menu configuration
    unless ( defined $self->{portalObject}->{applicationList} ) {
        $self->{portalObject}->abort(
            "XML menu configuration is deprecated",
"Please use lmMigrateConfFiles2ini to migrate your menu configuration"
        );
    }

    # Use configuration to get menu parameters
    my $applicationList = $self->{portalObject}->{applicationList};
    my $filteredList    = $self->_filter($applicationList);
    return $self->_displayConfCategory( "", $applicationList, $catlevel );
}

## @method string appslistDescription()
# Returns HTML code for application description.
# @return HTML string
sub appslistDescription {
    my $self = shift;

    # We no more use XML file for menu configuration
    unless ( defined $self->{portalObject}->{applicationList} ) {
        $self->{portalObject}->lmLog(
"XML menu configuration is deprecated. Please use lmMigrateConfFiles2ini to migrate your menu configuration",
            'error'
        );
        return "&nbsp;";
    }

    # Use configuration to get menu parameters
    my $applicationList = $self->{portalObject}->{applicationList};
    return $self->_displayConfDescription( "", $applicationList );
}

## @method string _displayConfCategory()
# Creates and returns HTML code for a category.
# @param catname Category name
# @param cathash Hash of category elements
# @param catlevel Category level
# @return HTML string
sub _displayConfCategory {
    my ( $self, $catname, $cathash, $catlevel ) = splice @_;
    my $html;
    my $key;

    # Init HTML list
    $html .= "<ul class=\"category cat-level-$catlevel\">\n";
    $html .= "<li class=\"catname\">\n";
    $html .= "<span>$catname</span>\n" if $catname;

    # Increase category level
    $catlevel++;

    # Extract applications from hash
    my $apphash;
    foreach $key ( keys %$cathash ) {
        next if $key =~ /(type|options)/;
        if ( $cathash->{$key}->{type} eq "application" ) {
            $apphash->{$key} = $cathash->{$key};
        }
    }

    # display applications first
    if ( scalar keys %$apphash > 0 ) {
        $html .= "<ul>";
        foreach $key ( keys %$apphash ) {
            $html .= $self->_displayConfApplication( $key, $apphash->{$key} );
        }
        $html .= "</ul>";
    }

    # Display subcategories
    foreach $key ( keys %$cathash ) {
        next if $key =~ /(type|options)/;
        if ( $cathash->{$key}->{type} eq "category" ) {
            $html .=
              $self->_displayConfCategory( $key, $cathash->{$key}, $catlevel );
        }
    }

    # Close HTML list
    $html .= "</li>\n";
    $html .= "</ul>\n";

    return $html;
}

## @method private string _userParam(string arg)
# Returns value of $arg variable stored in session.
# @param $arg string to modify
# @return string modified
sub _userParam {
    my ( $self, $arg ) = splice @_;
    $arg =~ s/\$([\w]+)/$self->{portalObject}->{sessionInfo}->{$1}/g;
    return $arg;
}

## @method private string _displayConfApplication()
# Creates HTML code for an application.
# @param $appid Application ID
# @param $apphash Hash of application elements
# @return HTML string
sub _displayConfApplication {
    my $self = shift;
    my ( $appid, $apphash ) = @_;
    my $html;
    my $key;

    # Get application items
    my $appname = $apphash->{options}->{name} || $appid;
    my $appuri  = $apphash->{options}->{uri}  || "";

    # Display application
    $html .=
        "<li title=\"$appid\" class=\"appname $appid\"><span>"
      . ( $appuri ? "<a href=\"$appuri\">$appname</a>" : "<a>$appname</a>" )
      . "</span>\n";

    # Detect sub applications
    my $subapphash;
    foreach $key ( keys %$apphash ) {
        next if $key =~ /(type|options)/;
        if ( $apphash->{$key}->{type} eq "application" ) {
            $subapphash->{$key} = $apphash->{$key};
        }
    }

    # Display sub applications
    if ( scalar keys %$subapphash > 0 ) {
        $html .= "<ul>";
        foreach $key ( keys %$subapphash ) {
            $html .=
              $self->_displayConfApplication( $key, $subapphash->{$key} );
        }
        $html .= "</ul>";
    }

    $html .= "</li>";
    return $html;
}

## @method private string _displayConfDescription()
# Create HTML code for application description.
# @param $appid Application ID
# @param $apphash Hash
# @return HTML string
sub _displayConfDescription {
    my $self = shift;
    my ( $appid, $apphash ) = @_;
    my $html;
    my $key;

    if ( defined $apphash->{type} and $apphash->{type} eq "application" ) {

        # Get application items
        my $appname = $apphash->{options}->{name} || $appid;
        my $appuri  = $apphash->{options}->{uri}  || "";
        my $appdesc = $apphash->{options}->{description};
        my $applogofile = $apphash->{options}->{logo};
        my $applogo     = $self->{apps}->{imgpath} . $applogofile
          if $applogofile;

        # Display application description
        $html .= "<div id=\"$appid\" class=\"appsdesc\">\n";
        $html .=
"<a href=\"$appuri\"><img src=\"$applogo\" alt=\"$appid logo\" /></a>\n"
          if $applogofile;
        $html .= "<p class=\"appname\">$appname</p>\n" if defined $appname;
        $html .= "<p class=\"appdesc\">$appdesc</p>\n" if defined $appdesc;
        $html .= "</div>\n";
    }

    # Sublevels
    foreach $key ( keys %$apphash ) {
        next if $key =~ /(type|options)/;
        $html .= $self->_displayConfDescription( $key, $apphash->{$key} );
    }

    return $html;
}

## @method private string _filter()
# Duplicate hash reference
# Remove unauthorized menu elements
# Hide empty categories
# @param $apphash Menu elements
# @return filtered hash
sub _filter {
    my ( $self, $apphash ) = splice @_;
    my $filteredHash;
    my $key;

    # Copy hash reference into a new hash
    foreach $key ( keys %$apphash ) {
        $filteredHash->{$key} = $apphash->{$key};
    }

    # Filter hash
    $self->_filterHash($filteredHash);

    # Hide empty categories
    $self->_isCategoryEmpty($filteredHash);

    return $filteredHash;
}

## @method private string _filterHash()
# Remove unauthorized menu elements
# @param $apphash Menu elements
# @return filtered hash
sub _filterHash {
    my $self = shift;
    my ($apphash) = @_;
    my $key;
    my $appkey;

    foreach $key ( keys %$apphash ) {
        next if $key =~ /(type|options)/;
        if ( $apphash->{$key}->{type} eq "category" ) {

            # Filter the category
            $self->_filterHash( $apphash->{$key} );
        }
        if ( $apphash->{$key}->{type} eq "application" ) {

            # Find sub applications and filter them
            foreach $appkey ( keys %{ $apphash->{$key} } ) {
                next if $appkey =~ /(type|options)/;

                # We have sub elements, so we filter them
                $self->_filterHash( $apphash->{$key} );
            }

            # Check rights
            my $appdisplay = $apphash->{$key}->{options}->{display}
              || "auto";
            my $appuri = $apphash->{$key}->{options}->{uri};

            # Remove if display is "no"
            delete $apphash->{$key} and next if ( $appdisplay eq "no" );

            # Keep node if display is "yes"
            next if ( $appdisplay eq "yes" );

            # Check grant function if display is "auto" (this is the default)
            delete $apphash->{$key} unless ( $self->_grant($appuri) );
            next;
        }
    }

}

## @method private void _isCategoryEmpty()
# Check if a category is empty
# @param $apphash Menu elements
# @return boolean
sub _isCategoryEmpty {
    my $self = shift;
    my ($apphash) = @_;
    my $key;

    # Test sub categories
    foreach $key ( keys %$apphash ) {
        next if $key =~ /(type|options)/;
        if ( $apphash->{$key}->{type} eq "category" ) {
            delete $apphash->{$key}
              if $self->_isCategoryEmpty( $apphash->{$key} );
        }
    }

    # Test this category
    if ( $apphash->{type} and $apphash->{type} eq "category" ) {

        # Temporary store 'options'
        my $tmp_options = $apphash->{options};

        delete $apphash->{type};
        delete $apphash->{options};

        if ( scalar( keys %$apphash ) ) {

            # There are sub categories or sub applications
            # Restore type and options
            $apphash->{type}    = "category";
            $apphash->{options} = $tmp_options;

            # Return false
            return 0;
        }
        else {

            # Return true
            return 1;
        }
    }
    return 0;
}

## @method private boolean _grant(string uri)
# Check user's authorization for $uri.
# @param $uri URL string
# @return True if granted
sub _grant {
    my ( $self, $uri ) = splice @_;
    $uri =~ m{(\w+)://([^/:]+)(:\d+)?(/.*)?$} or return 0;
    my ( $protocol, $vhost, $port );
    ( $protocol, $vhost, $port, $path ) = ( $1, $2, $3, $4 );
    $path ||= '/';
    $self->_compileRules()
      if ( $cfgNum != $self->{portalObject}->{cfgNum} );
    return -1 unless ( defined( $defaultCondition->{$vhost} ) );

    if ( defined $locationRegexp->{$vhost} ) {    # Not just a default rule
        for ( my $i = 0 ; $i < @{ $locationRegexp->{$vhost} } ; $i++ ) {
            if ( $path =~ $locationRegexp->{$vhost}->[$i] ) {
                return &{ $locationCondition->{$vhost}->[$i] }($self);
            }
        }
    }
    unless ( $defaultCondition->{$vhost} ) {
        $self->{portalObject}
          ->lmLog( "Application $uri did not match any configured virtual host",
            'warn' );
        return 0;
    }
    return &{ $defaultCondition->{$vhost} }($self);
    return 1;
}

## @method private boolean _compileRules()
# Parse configured rules and compile them
# @return True
sub _compileRules {
    my $self = shift;
    foreach my $vhost ( keys %{ $self->{portalObject}->{locationRules} } ) {
        my $i = 0;
        foreach ( keys %{ $self->{portalObject}->{locationRules}->{$vhost} } ) {
            if ( $_ eq 'default' ) {
                $defaultCondition->{$vhost} =
                  $self->_conditionSub(
                    $self->{portalObject}->{locationRules}->{$vhost}->{$_} );
            }
            else {
                $locationCondition->{$vhost}->[$i] =
                  $self->_conditionSub(
                    $self->{portalObject}->{locationRules}->{$vhost}->{$_} );
                $locationRegexp->{$vhost}->[$i] = qr/$_/;
                $i++;
            }
        }

        # Default policy
        $defaultCondition->{$vhost} ||= $self->_conditionSub('accept');
    }
    $cfgNum = $self->{portalObject}->{cfgNum};
    1;
}

## @method private CODE _conditionSub(string cond)
# Return subroutine giving authorization condition.
# @param $cond boolean expression
# @return Compiled routine
sub _conditionSub {
    my ( $self, $cond ) = splice @_;
    return sub { 1 }
      if ( $cond =~ /^(?:accept|unprotect)$/i );
    return sub { 0 }
      if ( $cond =~ /^(?:deny$|logout)/i );
    $cond =~ s/\$date/&POSIX::strftime("%Y%m%d%H%M%S",localtime())/e;
    $cond =~ s/\$(\w+)/\$self->{portalObject}->{sessionInfo}->{$1}/g;
    my $sub = "sub {my \$self = shift; return ( $cond )}";
    $sub = (
        SAFEWRAP
        ? $self->_safe->wrap_code_ref( $self->_safe->reval($sub) )
        : $self->_safe->reval($sub)
    );
    return $sub;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Portal::Menu - Enhanced menu to display to authenticated users

=head1 SYNOPSIS

    use Lemonldap::NG::Portal::Menu;
    my $menu = Lemonldap::NG::Portal::Menu->new(
      {
        portalObject => $portal,
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
    print $menu->appslistMenu;

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

Clement OUDOT E<lt>clement@oodo.netE<gt> E<lt>coudot@linagora.comE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2007 by Clement OUDOT E<lt>clement@oodo.netE<gt>
E<lt>coudot@linagora.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut


