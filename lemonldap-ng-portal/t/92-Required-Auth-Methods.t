use strict;
use Test::More;

require './t/parse-dir.pm';

testRequiredMethods(
    'Lemonldap::NG::Portal::Auth',
    [ qw(
          init
          authenticate
          authLogout
        )
    ],
    [qw(
      Custom
      PAM
      Proxy
      WebID
    )],
);

done_testing();
