##@file
# DBI common functions

##@class
# DBI common functions
package Lemonldap::NG::Portal::_DBI;

use DBI;
use base qw(Exporter);
use Lemonldap::NG::Portal::Simple;
use strict;

our @EXPORT = qw(dbh);

our $VERSION = '0.1';

## @method protected Lemonldap::NG::Portal::_DBI dbh()
# @param dbiChain
# @param dbiUser
# @param dbiPassword
# @return dbh object
sub dbh {
    my $self = shift;
    my $dbiChain = shift;
    my $dbiUser = shift;
    my $dbiPassword = shift;
    my $dbh;

    # Open connection to database
    eval {
        $dbh = DBI->connect_cached(
            $dbiChain,
            $dbiUser,
            $dbiPassword,
            { RaiseError => 1, },
        );
    };
    if ($@) {
        $self->lmLog("DBI connection error: $@", 'error');
        return 0;
    }

    return $dbh;
}

1;
