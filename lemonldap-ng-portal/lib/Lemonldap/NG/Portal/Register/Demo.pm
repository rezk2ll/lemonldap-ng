package Lemonldap::NG::Portal::Register::Demo;

use strict;
use Mouse;
use Lemonldap::NG::Portal::Main::Constants qw(PE_OK);

extends 'Lemonldap::NG::Portal::Main::Plugin';

our $VERSION = '2.0.0';

sub init {
    1;
}

# Compute a login from register infos
# @result Lemonldap::NG::Portal constant
sub computeLogin {
    my ( $self, $req ) = @_;

    # Get first letter of firstname and lastname
    my $login =
      substr( lc $req->datas->{registerInfo}->{firstname}, 0, 1 )
      . lc $req->datas->{registerInfo}->{lastname};

    $req->datas->{registerInfo}->{login} = $login;

    return PE_OK;
}

## @method int createUser
# Do nothing
# @result Lemonldap::NG::Portal constant
sub createUser {
    my ( $self, $req ) = @_;
    $Lemonldap::NG::Portal::UserDB::Demo::demoAccounts{ $req->datas
          ->{registerInfo}->{login} } = {
        uid => $req->datas->{registerInfo}->{login},
        cn  => $req->datas->{registerInfo}->{firstname} . ' '
          . $req->datas->{registerInfo}->{lastname},
        mail => $req->datas->{registerInfo}->{login} . '@badwolf.org',
          };
    return PE_OK;
}

1;
