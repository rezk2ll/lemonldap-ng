
package Lemonldap::NG::Handler::Main::Logger;

use Lemonldap::NG::Handler::API qw( :httpCodes );

## @rmethod void lmLog(string msg, string level, request r)
# Wrapper for Apache log system
# @param $msg message to log
# @param $level string (emerg|alert|crit|error|warn|notice|info|debug)
# @param $r optional Current request
sub lmLog {
    my ( $class, $msg, $level, $r ) = @_;
    my ( $module, $file, $line ) = caller();

    if ( $level eq 'debug' ) {
        $file =~ s#.+/##;
        Lemonldap::NG::Handler::API->lmLog( "$file($line): $msg", "debug", $r );
    } else {
        Lemonldap::NG::Handler::API->lmLog( "$file($line):", "debug", $r );

        Lemonldap::NG::Handler::API->lmLog( "Lemonldap::NG::Handler: $msg", $level, $r );
    }
}

1;
