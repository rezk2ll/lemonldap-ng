
package Lemonldap::NG::Handler::Main::Logger;

use Lemonldap::NG::Handler::API qw( :httpCodes );

## @rmethod void lmLog(string msg, string level)
# Wrapper for Apache log system
# @param $msg message to log
# @param $level string (emerg|alert|crit|error|warn|notice|info|debug)
sub lmLog {
    my ( $class, $msg, $level ) = @_;
    my ( $module, $file, $line ) = caller();

    if ( $level eq 'debug' ) {
        $file =~ s#.+/##;
        Lemonldap::NG::Handler::API->lmLog( "$file($line): $msg", "debug" );
    } else {
        Lemonldap::NG::Handler::API->lmLog( "$file($line):", "debug" );
        Lemonldap::NG::Handler::API->lmLog( "Lemonldap::NG::Handler: $msg", $level );
    }
}

1;
