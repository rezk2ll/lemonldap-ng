package Lemonldap::NG::Handler::Main::SharedVariables;

# Since handler has no instances but only static classes, this module provides
# classes properties with accessors

use strict;

our $VERSION = '2.0.0';

# Thread shared properties (if threads are available: needs to be loaded elsewhere)
our $_tshv = {
    tsv         => {},
    cfgNum      => 0,
    lastCheck   => 0,
    checkTime   => 600,
    lmConf      => {},
    localConfig => {},
    logLevel    => 'notice',
    _logLevel   => 2,
    logLevels   => {
        emerg  => 7,
        alert  => 6,
        crit   => 5,
        error  => 4,
        warn   => 3,
        notice => 2,
        info   => 1,
        debug  => 0,
    }
};

# Current sessions properties
our $_v = { session => {}, datas => {} };

BEGIN {
    # Thread shared accessors
    foreach (
        qw(tsv cfgNum lastCheck checkTime lmConf localConfig logLevel _logLevel logLevels)
      )
    {
        eval " sub $_ {
            my \$v = \$_[1];
            \$_tshv->{$_} = \$v if(defined \$v);
            return \$_tshv->{$_};
        }";
        die $@ if ($@);
    }

    # Current session accessors
    eval "threads::shared::share(\$_tshv);";
    foreach (qw(session datas datasUpdate)) {
        eval " sub $_ {
            my \$v = \$_[1];
            \$_v->{$_} = \$v if(\$v);
            return \$_v->{$_};
        }";
    }
}

1;
