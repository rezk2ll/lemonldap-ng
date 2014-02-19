package Lemonldap::NG::Manager::Cli;

# Required packages

use strict;
use Lemonldap::NG::Common::Conf;
use POSIX qw(strftime);

# Constants

our $VERSION = "1.3.3";

my $ERRORS = {
    TOO_FEW_ARGUMENTS  => "Too few arguments",
    UNKNOWN_ACTION     => "Unknown action",
    CONFIG_WRITE_ERROR => "Error while writting the configuration",
    CONFIG_READ_ERROR  => "Error while reading the configuration",
};

## @cmethod Lemonldap::NG::Manager::Cli new ()
# Create a new Lemonldap::NG::Manager::Cli object
#
# @return New Lemonldap::NG::Manager::Cli object
sub new {
    my ($class) = @_;

    my $self = { "confAccess" => Lemonldap::NG::Common::Conf->new() };

    $self->{conf} = $self->{confAccess}->getConf();

    bless( $self, $class );
    return $self;
}

## @method int saveConf ()
# Save LemonLDAP::NG configuration
#
# @return Configuration identifier
sub saveConf {
    my ($self) = @_;

    $self->{conf}->{cfgAuthor}   = "LemonLDAP::NG CLI";
    $self->{conf}->{cfgAuthorIP} = "127.0.0.1";
    $self->{conf}->{cfgDate}     = time();

    my $ret = $self->{confAccess}->saveConf( $self->{conf} );
    return $ret;
}

## @method int increment ()
# Force increment of configuration number
#
# @return nothing
sub increment {
    my ($self) = @_;

    # Update cache to save modified data
    $self->updateCache();

    $self->{confAccess}->{cfgNumFixed} = 0;
    $self->{confModified} = 1;

    return;
}

## @method updateCache()
# Update configuration cache
#
# @return nothing
sub updateCache {
    my ($self) = @_;

    # Get configuration from DB (update cache)
    my $cfgNum = $self->{conf}->{cfgNum};
    $self->{conf} = $self->{confAccess}->getDBConf( { cfgNum => $cfgNum } );

    print "Cache updated with configuration number $cfgNum\n";
}

## @method string determineMethod ()
# Determine the method from the arguments
#
# @return method name
sub determineMethod {
    my ( $self, $opt ) = @_;
    $opt =~ s/-(\w+)/ucfirst($1)/ge;
    return $opt;
}

## @method void setError (string str)
# Set error message
#
# @param str Text of the error
sub setError {
    my ( $self, $msg ) = @_;
    $self->{errormsg} = $msg;
}

## @method string getError ()
# Get error message
#
# @return Text of the error
sub getError {
    my ($self) = @_;
    return $self->{errormsg};
}

## @method int run (string method, array args)
# Run the requested method with @args
#
# @return result code of the method
sub run {
    my $self   = shift;
    my $method = shift;

    my @args;
    @args = @_ if ( @_ >= 1 );

    # perl black magic :)
    return ( @args >= 1 ) ? $self->$method(@args) : $self->$method();
}

## @method void set ( string variable, string value )
# Set the requested variable to the given value
#
# @return nothing
sub set {
    my ( $self, $var, $val ) = @_;
    unless ( $var and $val ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    $self->{conf}->{$var} = $val;
    $self->{confModified} = 1;
}

## @method void unset (string variable)
# Unset the requested variable
#
# @return nothing
sub unset {
    my ( $self, $var ) = @_;
    unless ($var) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{$var} ) ) {
        $self->setError( "$var: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no variable named $var" );
        return 0;
    }
    delete $self->{conf}->{$var};
    $self->{confModified} = 1;
}

## @method void get (string variable)
# Get the value of the requested variable
#
# @return nothing
sub get {
    my ( $self, $var ) = @_;
    unless ($var) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{$var} ) ) {
        $self->setError( "$var: "
              . $ERRORS->{CONFIG_READ_ERROR}
              . ": There is no variable named $var" );
        return 0;
    }

    if ( ref( $self->{conf}->{$var} ) ) {
        $self->setError("$var is not a scalar parameter. Try getHash $var");
        return 0;
    }

    print "$var = " . $self->{conf}->{$var} . "\n";
}

## @method void setHash ( string variable, string key, string value )
# Set for the requested variable the key/value pair
#
# @return nothing
sub setHash {
    my ( $self, $var, $key, $val ) = @_;
    unless ( $var and $key and $val ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    $self->{conf}->{$var}->{$key} = $val;
    $self->{confModified} = 1;
}

## @method void unsetHash (string variable, string key)
# Unset the key for the requested variable
#
# @return nothing
sub unsetHash {
    my ( $self, $var, $key ) = @_;
    unless ( $var and $key ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{$var} ) ) {
        $self->setError( "$var: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no variable named $var" );
        return 0;
    }
    if ( not defined( $self->{conf}->{$var}->{$key} ) ) {
        $self->setError( "$var: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no key $key for variable $var" );
        return 0;
    }

    delete $self->{conf}->{$var}->{$key};
    $self->{confModified} = 1;
}

## @method void getHash (string variable)
# Get all key/value pair of the requested variable
#
# @return nothing
sub getHash {
    my ( $self, $var ) = @_;
    unless ($var) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{$var} ) ) {
        $self->setError( "$var: "
              . $ERRORS->{CONFIG_READ_ERROR}
              . ": There is no variable named $var" );
        return 0;
    }

    unless ( ref( $self->{conf}->{$var} ) eq "HASH" ) {
        $self->setError("$var is not a Hash parameter. Try get $var.");
        return 0;
    }

    use Data::Dumper;
    print Dumper( $self->{conf}->{$var} ) . "\n";
}

## @method void setMacro (string macro, string value)
# Set the requested macro to the given value
#
# @return nothing
sub setMacro {
    my ( $self, $macro, $value ) = @_;
    unless ( $macro and $value ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    $self->{conf}->{macros}->{$macro} = $value;
    $self->{confModified} = 1;
}

## @method void unsetMacro (string macro)
# Unset the requested macro
#
# return nothing
sub unsetMacro {
    my ( $self, $macro ) = @_;
    unless ($macro) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{macros}->{$macro} ) ) {
        $self->setError( "$macro: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no macro named $macro" );
        return 0;
    }
    delete $self->{conf}->{macros}->{$macro};
    $self->{confModified} = 1;
}

## @method void getMacro (string macro)
# Get the value of the requested macro
#
# @return nothing
sub getMacro {
    my ( $self, $macro ) = @_;
    unless ($macro) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{macros}->{$macro} ) ) {
        $self->setError( "$macro: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no macro named $macro" );
        return 0;
    }
    print "$macro = " . $self->{conf}->{macros}->{$macro} . "\n";
}

## @method void appsSetCat ( int id, string name )
# Set the category name by its id
#
# @return nothing
sub appsSetCat {
    my ( $self, $id, $name ) = @_;
    unless ( $id and $name ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( defined( $self->{conf}->{applicationList}->{$id} ) ) {
        $self->{conf}->{applicationList}->{$id}->{catname} = $name;
    }
    else {
        $self->{conf}->{applicationList}->{$id} = {
            type => "category",
            name => $name
        };
    }
    $self->{confModified} = 1;
}

## @method void appsGetCat ( int id )
# Get a category name by its id
#
# @return nothing
sub appsGetCat {
    my ( $self, $id ) = @_;
    unless ($id) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{applicationList}->{$id} ) ) {
        $self->setError("$_: There is no category $id");
        return 0;
    }
    print "$id : " . $self->{conf}->{applicationList}->{$id}->{catname} . "\n";
}

## @method void appsAdd (int appId, int catId )
# Add a new application to a category
#
# @return nothing
sub appsAdd {
    my ( $self, $appId, $catId ) = @_;
    unless ( $appId and $catId ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{applicationList}->{$catId} ) ) {
        $self->setError( "$catId"
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Category $catId doesn't exist" );
        return 0;
    }
    if ( defined( $self->{conf}->{applicationList}->{$catId}->{$appId} ) ) {
        $self->setError( "$catId"
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Application $appId exists" );
    }
    $self->{conf}->{applicationList}->{$catId}->{$appId} = {
        type    => "application",
        options => {
            logo        => "demo.png",
            name        => $appId,
            description => $appId,
            display     => "auto",
            uri         => "http://test1.example.com"
        }
    };
    $self->{confModified} = 1;
}

## @cmethod void appsSetUri ( string id, string uri )
# Set given application's uri
#
# @return nothing
sub appsSetUri {
    my ( $self, $id, $uri ) = @_;
    unless ( $id and $uri ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    my $found = 0;

    while ( my ( $catId, $appList ) = each %{ $self->{conf}->{applicationList} }
        and $found != 1 )
    {
        while ( my ( $_appid, $app ) = each %{$appList} and $found != 1 ) {
            if ( $id eq $_appid ) {
                $app->{options}->{uri} = $uri;
                $found                 = 1;
                $self->{confModified}  = 1;
            }
        }
    }

    if ( $found == 0 ) {
        $self->setError( "$id: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Application $id not found" );
        return 0;
    }
}

## @method void appsSetName ( string id, string name )
# Set the name of the given application
#
# @return nothing
sub appsSetName {
    my ( $self, $id, $name ) = @_;
    unless ( $id and $name ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    my $found = 0;

    while ( my ( $catId, $appList ) = each %{ $self->{conf}->{applicationList} }
        and $found != 1 )
    {
        while ( my ( $_appid, $app ) = each %{$appList} and $found != 1 ) {
            if ( $id eq $_appid ) {
                $app->{options}->{name} = $name;
                $found                  = 1;
                $self->{confModified}   = 1;
            }
        }
    }
    if ( $found == 0 ) {
        $self->setError( "$id: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Application $id not found" );
        return 0;
    }
}

## @method void appsSetDesc ( string id, string desc )
# Set the description of the given application
#
# @return nothing
sub appsSetDesc {
    my ( $self, $id, $desc ) = @_;
    unless ( $id and $desc ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    my $found = 0;

    while ( my ( $catId, $appList ) = each %{ $self->{conf}->{applicationList} }
        and $found != 1 )
    {
        while ( my ( $_appid, $app ) = each %{$appList} and $found != 1 ) {
            if ( $id eq $_appid ) {
                $app->{options}->{description} = $desc;
                $found                         = 1;
                $self->{confModified}          = 1;
            }
        }
    }
    if ( $found == 0 ) {
        $self->setError( "$id: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Application $id not found" );
        return 0;
    }
}

## @method void appsSetLogo ( string id, string logo )
# Set the logo of the given application
#
# @return nothing
sub appsSetLogo {
    my ( $self, $id, $logo ) = @_;
    unless ( $id and $logo ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    my $found = 0;

    while ( my ( $catId, $appList ) = each %{ $self->{conf}->{applicationList} }
        and $found != 1 )
    {
        while ( my ( $_appid, $app ) = each %{$appList} and $found != 1 ) {
            if ( $id eq $_appid ) {
                $app->{options}->{logo} = $logo;
                $found                  = 1;
                $self->{confModified}   = 1;
            }
        }
    }
    if ( $found == 0 ) {
        $self->setError( "$id: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Application $id not found" );
        return 0;
    }
}

## @method void appsSetDisplay ( string id, string display )
# Set display setting of the given application
#
# @return nothing
sub appsSetDisplay {
    my ( $self, $id, $display ) = @_;
    unless ( $id and $display ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    my $found = 0;

    while ( my ( $catId, $appList ) = each %{ $self->{conf}->{applicationList} }
        and $found != 1 )
    {
        while ( my ( $_appid, $app ) = each %{$appList} and $found != 1 ) {
            if ( $id eq $_appid ) {
                $app->{options}->{display} = $display;
                $found                     = 1;
                $self->{confModified}      = 1;
            }
        }
    }

    if ( $found == 0 ) {
        $self->setError( "$id: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Application $id not found" );
        return 0;
    }

}

## @method void appsGet ( string id )
# Show all the given application's settings
#
# @return nothing
sub appsGet {
    my ( $self, $id ) = @_;
    unless ($id) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    my $found = 0;

    while ( my ( $catid, $applist ) = each %{ $self->{conf}->{applicationList} }
        and $found != 1 )
    {
        while ( my ( $_appid, $app ) = each %{$applist} and $found != 1 ) {
            if ( $id eq $_appid ) {
                print "Category $catid: "
                  . $self->{conf}->{applicationList}->{$catid}->{catname}
                  . "\n";
                print "Application $id: " . $app->{options}->{name} . "\n";
                print "- Description: " . $app->{options}->{description} . "\n";
                print "- URI: " . $app->{options}->{uri} . "\n";
                print "- Logo: " . $app->{options}->{logo} . "\n";
                print "- Display: " . $app->{options}->{display} . "\n";
                $found = 1;
            }
        }
    }

    if ( $found == 0 ) {
        $self->setError("Application $id not found");
        return 0;
    }
}

## @method void appsRm ( string id )
# Delete the given application from the configuration
#
# @return nothing
sub appsRm {
    my ( $self, $id ) = @_;
    unless ($id) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    my $found = 0;

    while ( my ( $catid, $applist ) = each %{ $self->{conf}->{applicationList} }
        and $found != 1 )
    {
        while ( my ( $_appid, $app ) = each %{$applist} and $found != 1 ) {
            if ( $id eq $_appid ) {
                delete $applist->{$id};
                $found = 1;
                $self->{confModified} = 1;
            }
        }
    }
    if ( $found == 0 ) {
        $self->setError("Application $id not found");
        return 0;
    }
}

## @method void rulesSet ( string uri, string expr, string rule )
# Set a rule for the given vhost
#
# @return nothing
sub rulesSet {
    my ( $self, $uri, $expr, $rule ) = @_;
    unless ( $uri and $expr and $rule ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{locationRules}->{$uri} ) ) {
        $self->{conf}->{locationRules}->{$uri} = {};
    }

    $self->{conf}->{locationRules}->{$uri}->{$expr} = $rule;
    $self->{confModified} = 1;
}

## @method void rulesUnset ( string uri, string expr)
# Unset a rule for the given vhost
#
# @return nothing
sub rulesUnset {
    my ( $self, $uri, $expr ) = @_;
    unless ( $uri and $expr ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{locationRules}->{$uri} ) ) {
        $self->setError( "$uri: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is rule $expr for virtual host $uri" );
        return 0;
    }

    delete $self->{conf}->{locationRules}->{$uri}->{$expr};
    $self->{confModified} = 1;
}

## @method void rulesGet ( string uri )
# Get the rules of the given vhost
#
# @return nothing
sub rulesGet {
    my ( $self, $uri ) = @_;
    unless ($uri) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{locationRules}->{$uri} ) ) {
        $self->setError("There is no virtual host $uri");
        return 0;
    }

    print "Virtual Host : $uri\n";

    while ( my ( $expr, $rule ) =
        each %{ $self->{conf}->{locationRules}->{$uri} } )
    {
        print "- $expr => $rule\n";
    }
}

## @method void exportVar ( string key, string val )
# export a variable
#
# @return nothing
sub exportVar {
    my ( $self, $key, $val ) = @_;
    unless ( $key and $val ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    $self->{conf}->{exportedVars}->{$key} = $val;
    $self->{confModified} = 1;
}

## @method void unexportVar ( string key )
# unexport a variable
#
# @return nothing
sub unexportVar {
    my ( $self, $key ) = @_;
    unless ($key) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{exportedVars}->{$key} ) ) {
        $self->setError("There is no exported variables named $key");
        return 0;
    }

    delete $self->{conf}->{exportedVars}->{$key};
    $self->{confModified} = 1;
}

## @method void getExportedVars ()
# print the exported variables of the configuration
#
# @return nothing
sub getExportedVars {
    my $self = shift;
    while ( my ( $key, $val ) = each %{ $self->{conf}->{exportedVars} } ) {
        print "$key = $val\n";
    }
}

## @method void exportHeader (string $vhost, string $header, string $expr )
# Export a header for the given vhost
#
# @return nothing
sub exportHeader {
    my ( $self, $vhost, $header, $expr ) = @_;
    unless ( $vhost and $header and $expr ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{exportedHeaders}->{$vhost} ) ) {
        $self->setError( "$vhost: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no virtual host $vhost\n" );
        return 0;
    }

    $self->{conf}->{exportedHeaders}->{$vhost}->{$header} = $expr;
    $self->{confModified} = 1;
}

## @method void unexportHeader ( string $vhost, string $header )
# Unexport the given header
#
# @return nothing
sub unexportHeader {
    my ( $self, $vhost, $header ) = @_;
    unless ( $vhost and $header ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{exportedHeaders}->{$vhost} ) ) {
        $self->setError( "$vhost: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no virtual host $vhost\n" );
        return 0;
    }

    if ( not defined( $self->{conf}->{exportedHeaders}->{$vhost}->{$header} ) )
    {
        $self->setError( "$_: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no header named $header exported for virtual host $vhost\n"
        );
        return 0;
    }

    delete $self->{conf}->{exportedHeaders}->{$vhost}->{$header};
    $self->{confModified} = 1;
}

## @method void getExportedHeaders ( string vhost )
# Give the exported headers for the given vhost
#
# @return nothing
sub getExportedHeaders {
    my ( $self, $vhost ) = @_;
    unless ($vhost) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{exportedHeaders}->{$vhost} ) ) {
        $self->setError( "$vhost: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no virtual host $vhost\n" );
        return 0;
    }

    while ( my ( $header, $expr ) =
        each %{ $self->{conf}->{exportedHeaders}->{$vhost} } )
    {
        print "$header : $expr\n";
    }
}

## @method void vhostAdd ( string vhost )
# Add a new vhost
#
# @return nothing
sub vhostAdd {
    my ( $self, $vhost ) = @_;
    unless ($vhost) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if (   defined( $self->{conf}->{vhostOptions}->{$vhost} )
        or defined( $self->{conf}->{locationRules}->{$vhost} )
        or defined( $self->{conf}->{exportedHeaders}->{$vhost} ) )
    {
        $self->setError( "$vhost: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": Virtual host $vhost already exist" );
        return 0;
    }

    $self->{conf}->{vhostOptions}->{$vhost} = {
        vhostMaintenance => '0',
        vhostPort        => '-1',
        vhostHttps       => '-1'
    };

    $self->{conf}->{locationRules}->{$vhost}   = { default     => "deny" };
    $self->{conf}->{exportedHeaders}->{$vhost} = { "Auth-User" => "\$uid" };
    $self->{confModified}                      = 1;

}

## @method void vhostDel ( string vhost )
# Drop a vhost
#
# @return nothing
sub vhostDel {
    my ( $self, $vhost ) = @_;
    unless ($vhost) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    my $error  = "No virtual host in: ";
    my $nerror = 0;

    if ( not defined( $self->{conf}->{vhostOptions}->{$vhost} ) ) {
        $nerror++;
        $error .= "vhostOptions ";
    }
    else {
        delete $self->{conf}->{vhostOptions}->{$vhost};
    }

    if ( not defined( $self->{conf}->{locationRules}->{$vhost} ) ) {
        $nerror++;
        $error .= "locationRules ";
    }
    else {
        delete $self->{conf}->{locationRules}->{$vhost};
    }

    if ( not defined( $self->{conf}->{exportedHeaders}->{$vhost} ) ) {
        $nerror++;
        $error .= "exportedHeaders ";
    }
    else {
        delete $self->{conf}->{exportedHeaders}->{$vhost};
    }

    if ( $nerror == 3 ) {
        $error .= ". aborting...";
        $self->setError(
            "$vhost: " . $ERRORS->{CONFIG_WRITE_ERROR} . ": $error" );
        return 0;
    }
    elsif ( $nerror != 0 ) {
        $error .= ". ignoring...";
        $self->setError(
            "$vhost: " . $ERRORS->{CONFIG_WRITE_ERROR} . ": $error" );
    }
    $self->{confModified} = 1;
}

## @method void vhostSetPort ( string vhost, int port )
# Set given vhost's port
#
# @return nothing
sub vhostSetPort {
    my ( $self, $vhost, $port ) = @_;
    unless ( $vhost and $port ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{vhostOptions}->{$vhost} ) ) {
        if (    not defined( $self->{conf}->{locationRules}->{$vhost} )
            and not defined( $self->{conf}->{exportedHeaders}->{$vhost} ) )
        {
            $self->setError( "$vhost: "
                  . $ERRORS->{CONFIG_WRITE_ERROR}
                  . ": There is no virtual host $vhost" );
            return 0;
        }
        else {
            $self->{conf}->{vhostOptions}->{$vhost} = {
                vhostPort        => $port,
                vhostHttps       => '-1',
                vhostMaintenance => '0'
            };
        }
    }
    else {
        $self->{conf}->{vhostOptions}->{$vhost}->{vhostPort} = $port;
    }
    $self->{confModified} = 1;
}

## @method vhostSetHttps ( string vhost, int https )
# Set the https parameter on the given vhost
#
# @return nothing
sub vhostSetHttps {
    my ( $self, $vhost, $https ) = @_;
    unless ( $vhost and $https ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }
    if ( not defined( $self->{conf}->{vhostOptions}->{$vhost} ) ) {
        if (    not defined( $self->{conf}->{locationRules}->{$vhost} )
            and not defined( $self->{conf}->{exportedHeaders}->{$vhost} ) )
        {
            $self->setError( "$vhost: "
                  . $ERRORS->{CONFIG_WRITE_ERROR}
                  . ": There is no virtual host $vhost" );
            return 0;
        }
        else {
            $self->{conf}->{vhostOptions}->{$vhost} = {
                vhostPort        => '-1',
                vhostHttps       => $https,
                vhostMaintenance => '0'
            };
        }
    }
    else {
        $self->{conf}->{vhostOptions}->{$vhost}->{vhostHttps} = $https;
    }
    $self->{confModified} = 1;
}

## @method vhostSetMaintenance ( string vhost, int off )
# Set the maintenance flag on a vhost
#
# @return nothing
sub vhostSetMaintenance {
    my ( $self, $vhost, $off ) = @_;
    unless ( $vhost and $off ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{vhostOptions}->{$vhost} ) ) {
        if (    not defined( $self->{conf}->{locationRules}->{$vhost} )
            and not defined( $self->{conf}->{exportedHeaders}->{$vhost} ) )
        {
            $self->setError( "$vhost: "
                  . $ERRORS->{CONFIG_WRITE_ERROR}
                  . ": There is no virtual host $vhost" );
            return 0;
        }
        else {
            $self->{conf}->{vhostOptions}->{$vhost} = {
                vhostPort        => '-1',
                vhostHttps       => '-1',
                vhostMaintenance => $off
            };
        }
    }
    else {
        $self->{conf}->{vhostOptions}->{$vhost}->{vhostMaintenance} = $off;
    }
    $self->{confModified} = 1;
}

## @method void vhostList ()
# list all vhosts
#
# @return nothing
sub vhostList {
    my ($self) = @_;

    foreach my $vhost ( sort keys %{ $self->{conf}->{locationRules} } ) {
        print "- $vhost\n";
    }
}

## @method void vhostListOptions ( string vhost )
# list all options of each vhosts
#
# @return nothing
sub vhostListOptions {
    my ( $self, $vhost ) = @_;

    unless ($vhost) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    my $vhostoptions = $self->{conf}->{vhostOptions}->{$vhost};
    if ($vhostoptions) {
        print "- Maintenance: $vhostoptions->{vhostMaintenance}\n";
        print "- Port: $vhostoptions->{vhostPort}\n";
        print "- HTTPS: $vhostoptions->{vhostHttps}\n";
    }
    else {
        print "No options defined for $vhost\n";
    }
}

## @method reloadUrls ()
# Print reloads urls by vhost
#
# @return nothing
sub reloadUrls {
    my ($self) = shift;

    while ( my ( $vhost, $url ) = each %{ $self->{conf}->{reloadUrls} } ) {
        print "- $vhost => $url\n";
    }
}

## @method void reloadUrlAdd ( string vhost, string url)
# Add a new reload url for the given vhost
#
# @return nothing
sub reloadUrlAdd {
    my ( $self, $vhost, $url ) = @_;
    unless ( $vhost and $url ) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    $self->{conf}->{reloadUrls}->{$vhost} = $url;
    $self->{confModified} = 1;
}

## @method void reloadUrlDel ( string vhost )
# Delete the given vhost's reload url
#
# @return nothing
sub reloadUrlDel {
    my ( $self, $vhost ) = @_;
    unless ($vhost) {
        $self->setError( $ERRORS->{TOO_FEW_ARGUMENTS} );
        return 0;
    }

    if ( not defined( $self->{conf}->{reloadUrls}->{$vhost} ) ) {
        $self->setError( "$vhost: "
              . $ERRORS->{CONFIG_WRITE_ERROR}
              . ": There is no reload URLs setted for $vhost" );
        return 0;
    }

    delete $self->{conf}->{reloadUrls}->{$vhost};
    $self->{confModified} = 1;
}

## @method info ()
# print information on configuration
#
# @return nothing
sub info {

    my ($self) = @_;

    print "Information on current configuration:\n";
    print "Number: " . $self->{conf}->{cfgNum} . "\n";
    print "Date: "
      . strftime( "%Y/%m/%d %Hh%M", localtime( $self->{conf}->{cfgDate} ) )
      . "\n"
      if defined $self->{conf}->{cfgDate};
    print "Author: " . $self->{conf}->{cfgAuthor} . "\n"
      if defined $self->{conf}->{cfgAuthor};
    print "Author IP: " . $self->{conf}->{cfgAuthorIP} . "\n"
      if defined $self->{conf}->{cfgAuthorIP};
}

## @method void help ()
# print help message
#
# @return nothing
sub help {
    my ($self) = @_;

    print STDERR "

Global actions
==============

  lemonldap-ng-cli help - display this message
  lemonldap-ng-cli info - show current configuration information
  lemonldap-ng-cli update-cache - reload current configuration into cache
  lemonldap-ng-cli increment - save current configuration into a new one

Scalar parameters (key/value form)
==================================

  lemonldap-ng-cli set <variable> <value>
  lemonldap-ng-cli unset <variable>
  lemonldap-ng-cli get <variable>

Hash parameters
===============

  lemonldap-ng-cli set-hash <variable> <key> <value>
  lemonldap-ng-cli unset-hash <variable> <key>
  lemonldap-ng-cli get-hash <variable>

Variables
=========

Exported variables
------------------

  lemonldap-ng-cli export-var <key> <value>
  lemonldap-ng-cli unexport-var <key>
  lemonldap-ng-cli get-exported-vars

Macros
------

  lemonldap-ng-cli set-macro <macro name> <perl expression>
  lemonldap-ng-cli unset-macro <macro name>
  lemonldap-ng-cli get-macro <macro name>

Application menu
================

Categories
----------

  lemonldap-ng-cli apps-set-cat <cat id> <cat name>
  lemonldap-ng-cli apps-get-cat <cat id>
  
Applications
------------

  lemonldap-ng-cli apps-add <app id> <cat id>
  lemonldap-ng-cli apps-set-uri <app id> <app uri>
  lemonldap-ng-cli apps-set-name <app id> <app name>
  lemonldap-ng-cli apps-set-desc <app id> <app description>
  lemonldap-ng-cli apps-set-logo <app id> <logo>
  lemonldap-ng-cli apps-set-display <app id> <app display>
  
  lemonldap-ng-cli apps-get <app id>
  lemonldap-ng-cli apps-rm <app id>

Virtual hosts
=============

  lemonldap-ng-cli vhost-add <virtual host uri>
  lemonldap-ng-cli vhost-del <virtual host>
  lemonldap-ng-cli vhost-list

Exported headers
----------------

  lemonldap-ng-cli export-header <virtual host> <HTTP header> <perl expression>
  lemonldap-ng-cli unexport-header <virtual host> <HTTP header>
  lemonldap-ng-cli get-exported-headers <virtual host>

Rules
-----

  lemonldap-ng-cli rules-set <virtual host> <expr> <rule>
  lemonldap-ng-cli rules-unset <virtual host> <expr>
  lemonldap-ng-cli rules-get <virtual host>

Options
-------

  lemonldap-ng-cli vhost-set-port <virtual host> <port>
  lemonldap-ng-cli vhost-set-https <virtual host> <value>
  lemonldap-ng-cli vhost-set-maintenance  <virtual host> <value>
  lemonldap-ng-cli vhost-list-options <virtual host>

Reload URLs
===========

  lemonldap-ng-cli reload-urls
  lemonldap-ng-cli reload-url-add <vhost> <url>
  lemonldap-ng-cli reload-url-del <vhost>

";

}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Manager::Cli - Command Line Interface to edit LemonLDAP::NG configuration.

=head1 SYNOPSIS

    use Lemonldap::NG::Manager::Cli;
  
    $cli = new Lemonldap::NG::Manager::Cli;
    $action = shift(@ARGV);
    $method = $cli->determineMethod($action);
    $cli->run($method, @ARGV);
    $ret = $cli->saveConf();

=head1 DESCRIPTION

Lemonldap::NG::Manager::Cli allow user to edit the configuration of LemonLDAP::NG via the
command line.

=head1 SEE ALSO

L<Lemonldap::NG>, L<Lemonldap::NG::Common::Conf>

=head1 AUTHOR

David Delassus E<lt>david.jose.delassus@gmail.comE<gt>
Clement Oudot E<lt>clem.oudot@gmail.comE<gt>
Sandro Cazzaniga E<lt>cazzaniga.sandro@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012, by David Delassus
Copyright (C) 2013, by Clement Oudot, Sandro Cazzaniga

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
