package Lemonldap::NG::Common::Logger::Apache2;

sub AUTOLOAD {
    shift;
    $AUTOLOAD =~ s/.*:://;
    return Apache2::ServerRec->log->$AUTOLOAD(@_);
};

1;
