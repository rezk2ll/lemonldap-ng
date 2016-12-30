##@file
# menu for lemonldap::ng portal
package Lemonldap::NG::Portal::Main::Menu;

use strict;
use utf8;
use Mouse;
use Clone 'clone';

extends 'Lemonldap::NG::Common::Module';

# PROPERTIES

has menuModules => (
    is      => 'rw',
    builder => sub {
        my $conf = $_[0]->{conf}->{menuModule};
        my @res;
        foreach (qw(Appslist ChangePassword LoginHistory Logout)) {
            my $cond = $conf->{"portalDisplay$_"} // 1;
            $_[0]
              ->p->lmLog( "Evaluate condition $cond for module $_", 'debug' );
            my $tmp =
              $_[0]->{p}->HANDLER->buildSub($cond);
            push @res, [ $_, $tmp ] if ($tmp);
        }
        return \@res;
    }
);

has imgPath => (
    is      => 'rw',
    builder => sub {
        return $_[0]->{conf}->{impgPath} || $_[0]->{conf}->{staticPrefix} . '/logos';
    }
);

# INITIALIZATION

sub init {
    1;
}

# RUNNING METHODS

# Prepare menu template elements
# Returns hash (=list) containing :
#  - DISPLAY_MODULES
#  - DISPLAY_TAB
#  - AUTH_ERROR
#  - AUTH_ERROR_TYPE
sub params {
    my ( $self, $req ) = @_;
    $self->{conf}->{imgPath} ||= $self->{staticPrefix};
    my %res;

    # Tab to display
    # Get the tab URL parameter

    # Force password tab in case of password error
    if (
        $req->menuError
        and scalar(
            grep { $_ == $req->menuError } (
                25,    #PE_PP_CHANGE_AFTER_RESET
                26,    #PE_PP_PASSWORD_MOD_NOT_ALLOWED
                27,    #PE_PP_MUST_SUPPLY_OLD_PASSWORD
                28,    #PE_PP_INSUFFICIENT_PASSWORD_QUALITY
                29,    #PE_PP_PASSWORD_TOO_SHORT
                30,    #PE_PP_PASSWORD_TOO_YOUNG
                31,    #PE_PP_PASSWORD_IN_HISTORY
                32,    #PE_PP_GRACE
                33,    #PE_PP_EXP_WARNING
                34,    #PE_PASSWORD_MISMATCH
                39,    #PE_BADOLDPASSWORD
                74,    #PE_MUST_SUPPLY_OLD_PASSWORD
            )
        )
      )
    {
        $res{DISPLAY_TAB} = "password";
    }

    # else calculate modules to display
    else {
        $res{DISPLAY_TAB} = scalar( grep /^(password|logout|loginHistory)$/,
            $req->param("tab") // '' )
          || "applist";
    }
    $res{DISPLAY_MODULES} = $self->displayModules($req);
    $res{AUTH_ERROR_TYPE} =
      $req->error_type( $res{AUTH_ERROR} = $req->menuError );

    return %res;
}

## @method arrayref displayModules()
# List modules that can be displayed in Menu
# @return modules list
sub displayModules {
    my ( $self, $req ) = @_;
    my $displayModules = [];

    # Foreach module, eval condition
    # Store module in result if condition is valid
    foreach my $module ( @{ $self->menuModules } ) {
        $self->lmLog( "Check if $module->[0] has to be displayed", 'debug' );

        if ( $module->[1]->() ) {
            my $moduleHash = { $module->[0] => 1 };
            if ( $module->[0] eq 'Appslist' ) {
                $moduleHash->{'APPSLIST_LOOP'} = $self->appslist($req);
            }
            elsif ( $module->[0] eq 'LoginHistory' ) {
                $moduleHash->{'SUCCESS_LOGIN'} =
                  $self->p->mkSessionArray(
                    $req->{sessionInfo}->{loginHistory}->{successLogin},
                    "", 0, 0 );
                $moduleHash->{'FAILED_LOGIN'} =
                  $self->p->mkSessionArray(
                    $req->{sessionInfo}->{loginHistory}->{failedLogin},
                    "", 0, 1 );
            }
            push @$displayModules, $moduleHash;
        }
    }

    return $displayModules;
}

## @method arrayref appslist()
# Returns categories and applications list as HTML::Template loop
# @return categories and applications list
sub appslist {
    my ( $self, $req ) = @_;
    my $appslist = [];

    return $appslist unless defined $self->conf->{applicationList};

    # Reset level
    my $catlevel = 0;

    my $applicationList = clone( $self->conf->{applicationList} );
    my $filteredList = $self->_filter( $req, $applicationList );
    push @$appslist,
      $self->_buildCategoryHash( $req, "", $filteredList, $catlevel );

    # We must return an ARRAY ref
    return ( ref $appslist->[0]->{categories} eq "ARRAY" )
      ? $appslist->[0]->{categories}
      : [];
}

## @method private hashref _buildCategoryHash(string catname,hashref cathash, int catlevel)
# Build hash for a category
# @param catname Category name
# @param cathash Hash of category elements
# @param catlevel Category level
# @return Category Hash
sub _buildCategoryHash {
    my ( $self, $req, $catid, $cathash, $catlevel ) = @_;
    my $catname = $cathash->{catname} || $catid;
    utf8::decode($catname);
    my $applications;
    my $categories;

    # Extract applications from hash
    my $apphash;
    foreach my $catkey ( sort keys %$cathash ) {
        next if $catkey =~ /(type|options|catname)/;
        if ( $cathash->{$catkey}->{type} eq "application" ) {
            $apphash->{$catkey} = $cathash->{$catkey};
        }
    }

    # Display applications first
    if ( scalar keys %$apphash > 0 ) {
        foreach my $appkey ( sort keys %$apphash ) {
            push @$applications,
              $self->_buildApplicationHash( $appkey, $apphash->{$appkey} );
        }
    }

    # Display subcategories
    foreach my $catkey ( sort keys %$cathash ) {
        next if $catkey =~ /(type|options|catname)/;
        if ( $cathash->{$catkey}->{type} eq "category" ) {
            push @$categories,
              $self->_buildCategoryHash( $req, $catkey, $cathash->{$catkey},
                $catlevel + 1 );
        }
    }

    my $categoryHash = {
        category => 1,
        catname  => $catname,
        catid    => $catid,
        catlevel => $catlevel
    };
    $categoryHash->{applications} = $applications if $applications;
    $categoryHash->{categories}   = $categories   if $categories;
    return $categoryHash;
}

## @method private hashref _buildApplicationHash(string appid, hashref apphash)
# Build hash for an application
# @param $appid Application ID
# @param $apphash Hash of application elements
# @return Application Hash
sub _buildApplicationHash {
    my ( $self, $appid, $apphash ) = @_;
    my $applications;

    # Get application items
    my $appname = $apphash->{options}->{name} || $appid;
    my $appuri  = $apphash->{options}->{uri}  || "";
    my $appdesc = $apphash->{options}->{description};
    my $applogo = $apphash->{options}->{logo};
    utf8::decode($appname);
    utf8::decode($appdesc) if $appdesc;

    # Detect sub applications
    my $subapphash;
    foreach my $key ( sort keys %$apphash ) {
        next if $key =~ /(type|options|catname)/;
        if ( $apphash->{$key}->{type} eq "application" ) {
            $subapphash->{$key} = $apphash->{$key};
        }
    }

    # Display sub applications
    if ( scalar keys %$subapphash > 0 ) {
        foreach my $appkey ( sort keys %$subapphash ) {
            push @$applications,
              $self->_buildApplicationHash( $appkey, $subapphash->{$appkey} );
        }
    }

    my $applicationHash = {
        application => 1,
        appname     => $appname,
        appuri      => $appuri,
        appdesc     => $appdesc,
        applogo     => $applogo,
        appid       => $appid,
    };
    $applicationHash->{applications} = $applications if $applications;
    return $applicationHash;
}

## @method string _displayConfCategory(string catname, hashref cathash, int catlevel)
# Creates and returns HTML code for a category.
# @param catname Category name
# @param cathash Hash of category elements
# @param catlevel Category level
# @return HTML string
sub _displayConfCategory {
    my ( $self, $catname, $cathash, $catlevel ) = @_;
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
        next if $key =~ /(type|options|catname)/;
        if (    $cathash->{$key}->{type}
            and $cathash->{$key}->{type} eq "application" )
        {
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
        next if $key =~ /(type|options|catname)/;
        if (    $cathash->{$key}->{type}
            and $cathash->{$key}->{type} eq "category" )
        {
            $html .=
              $self->_displayConfCategory( $key, $cathash->{$key}, $catlevel );
        }
    }

    # Close HTML list
    $html .= "</li>\n";
    $html .= "</ul>\n";

    return $html;
}

## @method private string _displayConfApplication(string appid, hashref apphash)
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
        next if $key =~ /(type|options|catname)/;
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

## @method private string _displayConfDescription(string appid, hashref apphash)
# Create HTML code for application description.
# @param $appid Application ID
# @param $apphash Hash
# @return HTML string
sub _displayConfDescription {
    my $self = shift;
    my ( $appid, $apphash ) = @_;
    my $html = "";
    my $key;

    if ( defined $apphash->{type} and $apphash->{type} eq "application" ) {

        # Get application items
        my $appname = $apphash->{options}->{name} || $appid;
        my $appuri  = $apphash->{options}->{uri}  || "";
        my $appdesc = $apphash->{options}->{description};
        my $applogofile = $apphash->{options}->{logo};
        my $applogo     = $self->imgPath . $applogofile
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
        next if $key =~ /(type|options|catname)/;
        $html .= $self->_displayConfDescription( $key, $apphash->{$key} );
    }

    return $html;
}

## @method private string _filter(hashref apphash)
# Duplicate hash reference
# Remove unauthorized menu elements
# Hide empty categories
# @param $apphash Menu elements
# @return filtered hash
sub _filter {
    my ( $self, $req, $apphash ) = @_;
    my $filteredHash;
    my $key;

    # Copy hash reference into a new hash
    foreach $key ( keys %$apphash ) {
        $filteredHash->{$key} = $apphash->{$key};
    }

    # Filter hash
    $self->_filterHash( $req, $filteredHash );

    # Hide empty categories
    $self->_isCategoryEmpty($filteredHash);

    return $filteredHash;
}

## @method private string _filterHash(hashref apphash)
# Remove unauthorized menu elements
# @param $apphash Menu elements
# @return filtered hash
sub _filterHash {
    my ( $self, $req, $apphash ) = @_;

    foreach my $key ( keys %$apphash ) {
        next if $key =~ /(type|options|catname)/;
        if (    $apphash->{$key}->{type}
            and $apphash->{$key}->{type} eq "category" )
        {

            # Filter the category
            $self->_filterHash( $req, $apphash->{$key} );
        }
        if (    $apphash->{$key}->{type}
            and $apphash->{$key}->{type} eq "application" )
        {

            # Find sub applications and filter them
            foreach my $appkey ( keys %{ $apphash->{$key} } ) {
                next if $appkey =~ /(type|options|catname)/;

                # We have sub elements, so we filter them
                $self->_filterHash( $req, $apphash->{$key} );
            }

            # Check rights
            my $appdisplay = $apphash->{$key}->{options}->{display}
              || "auto";
            my ( $vhost, $appuri ) =
              $apphash->{$key}->{options}->{uri} =~ m#^https?://([^/]*)(.*)#;
            $vhost =~ s/:\d+$//;
            $appuri ||= '/';

            # Remove if display is "no" or "off"
            delete $apphash->{$key} and next if ( $appdisplay =~ /^(no|off)$/ );

            # Keep node if display is "yes" or "on"
            next if ( $appdisplay =~ /^(yes|on)$/ );

            # Check grant function if display is "auto" (this is the default)
            delete $apphash->{$key}
              unless (
                $self->p->HANDLER->grant(
                    $req->sessionInfo,
                    $appuri, undef, $vhost
                )
              );
            next;
        }
    }

}

## @method private void _isCategoryEmpty(hashref apphash)
# Check if a category is empty
# @param $apphash Menu elements
# @return boolean
sub _isCategoryEmpty {
    my $self = shift;
    my ($apphash) = @_;
    my $key;

    # Test sub categories
    foreach $key ( keys %$apphash ) {
        next if $key =~ /(type|options|catname)/;
        if (    $apphash->{$key}->{type}
            and $apphash->{$key}->{type} eq "category" )
        {
            delete $apphash->{$key}
              if $self->_isCategoryEmpty( $apphash->{$key} );
        }
    }

    # Test this category
    if ( $apphash->{type} and $apphash->{type} eq "category" ) {

        # Temporary store 'options'
        my $tmp_options = $apphash->{options};
        my $tmp_catname = $apphash->{catname};

        delete $apphash->{type};
        delete $apphash->{options};
        delete $apphash->{catname};

        if ( scalar( keys %$apphash ) ) {

            # There are sub categories or sub applications
            # Restore type and options
            $apphash->{type}    = "category";
            $apphash->{options} = $tmp_options;
            $apphash->{catname} = $tmp_catname;

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

1;
