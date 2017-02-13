package Lemonldap::NG::Common::Logger::Apache2;

use Apache2::ServerRec;

sub new{
    return bless {}, shift;
}

sub AUTOLOAD {
    shift;
    $AUTOLOAD =~ s/.*:://;
    return Apache2::ServerRec->log->$AUTOLOAD(@_);
};

1;
