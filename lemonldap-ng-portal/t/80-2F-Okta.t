use warnings;
use Test::More;
use strict;
use IO::String;
use Data::Dumper;

require 't/test-lib.pm';

my $client = LLNG::Manager::Test->new(
    {
        ini => {
            logLevel             => 'error',
            authentication       => 'Demo',
            userDB               => 'Same',
            okta2fActivation     => 1,
            okta2fAdminURL       => 'https://fake/',
            okta2fApiKey         => 'fake',
            okta2fLoginAttribute => "uid",
            restSessionServer    => 1,
        }
    }
);

my $res;
ok( $res = $client->_get( '/', accept => 'text/html' ), 'Get Portal', );
my ( $host, $url, $query ) = expectForm( $res, '#', undef, 'user', 'password' );

$query =~ s/user=/user=dwho/;
$query =~ s/password=/password=dwho/;
ok(
    $res = $client->_post(
        '/',
        IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Auth query'
);

( $host, $url, $query ) = expectForm( $res, undef, '/okta2fchoice' );

$query =~ s/sf=/sf=sms2gt8gzgEBPUWBIFHN/;
ok(
    $res = $client->_post(
        '/okta2fchoice',
        IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Choose SMS'
);

( $host, $url, $query ) =
  expectForm( $res, undef, '/okta2fcheck?skin=bootstrap' );

$query =~ s/extcode=/extcode=1234/;
ok(
    $res = $client->_post(
        '/okta2fcheck',
        IO::String->new($query),
        length => length($query),
        accept => 'text/html',
    ),
    'Send code'
);
my $id   = expectCookie($res);
my $attr = expectSessionAttributes(
    $client, $id,
    _auth => "Demo",
    _2f   => "okta",
);
$client->logout($id);
clean_sessions();

done_testing();

# Override Okta API
# Sample data from https://developer.okta.com/docs/reference/core-okta-api/
no warnings 'redefine';

sub Lemonldap::NG::Portal::Lib::Okta::searchProfile {
    return '[
  {
    "id": "oktaID0fTheFakeUser",
    "status": "ACTIVE",
    "created": "2013-06-24T16:39:18.000Z",
    "activated": "2013-06-24T16:39:19.000Z",
    "statusChanged": "2013-06-24T16:39:19.000Z",
    "lastLogin": "2013-06-24T17:39:19.000Z",
    "lastUpdated": "2013-07-02T21:36:25.344Z",
    "passwordChanged": "2013-07-02T21:36:25.344Z",
    "profile": {
      "firstName": "Isaac",
      "lastName": "Brock",
      "email": "isaac.brock@example.com",
      "login": "isaac.brock@example.com",
      "mobilePhone": "555-415-1337"
    },
    "credentials": {
      "password": {},
      "recovery_question": {
        "question": "Who iss a major player in the cowboy scene?"
      },
      "provider": {
        "type": "OKTA",
        "name": "OKTA"
      }
    },
    "_links": {
      "self": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser"
      }
    }
  }
]';

}

sub Lemonldap::NG::Portal::Lib::Okta::searchFactors {
    return '[
  {
    "id": "ufs2bysphxKODSZKWVCT",
    "factorType": "question",
    "provider": "OKTA",
    "vendorName": "OKTA",
    "status": "ACTIVE",
    "created": "2014-04-15T18:10:06.000Z",
    "lastUpdated": "2014-04-15T18:10:06.000Z",
    "profile": {
      "question": "favorite_art_piece",
      "questionText": "What is your favorite piece of art?"
    },
    "_links": {
      "questions": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/questions",
        "hints": {
          "allow": [
            "GET"
          ]
        }
      },
      "self": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/ufs2bysphxKODSZKWVCT",
        "hints": {
          "allow": [
            "GET",
            "DELETE"
          ]
        }
      },
      "user": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser",
        "hints": {
          "allow": [
            "GET"
          ]
        }
      }
    }
  },
  {
    "id": "ostf2gsyictRQDSGTDZE",
    "factorType": "token:software:totp",
    "provider": "OKTA",
    "status": "PENDING_ACTIVATION",
    "created": "2014-06-27T20:27:33.000Z",
    "lastUpdated": "2014-06-27T20:27:33.000Z",
    "profile": {
      "credentialId": "dade.murphy@example.com"
    },
    "_links": {
      "next": {
        "name": "activate",
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/ostf2gsyictRQDSGTDZE/lifecycle/activate",
        "hints": {
          "allow": [
            "POST"
          ]
        }
      },
      "self": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/ostf2gsyictRQDSGTDZE",
        "hints": {
          "allow": [
            "GET"
          ]
        }
      },
      "user": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser",
        "hints": {
          "allow": [
            "GET"
          ]
        }
      }
    },
    "_embedded": {
      "activation": {
        "timeStep": 30,
        "sharedSecret": "HE64TMLL2IUZW2ZLB",
        "encoding": "base32",
        "keyLength": 16
      }
    }
  },
  {
    "id": "sms2gt8gzgEBPUWBIFHN",
    "factorType": "sms",
    "provider": "OKTA",
    "status": "ACTIVE",
    "created": "2014-06-27T20:27:26.000Z",
    "lastUpdated": "2014-06-27T20:27:26.000Z",
    "profile": {
      "phoneNumber": "+1-555-415-1337"
    },
    "_links": {
      "verify": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/sms2gt8gzgEBPUWBIFHN/verify",
        "hints": {
          "allow": [
            "POST"
          ]
        }
      },
      "self": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/sms2gt8gzgEBPUWBIFHN",
        "hints": {
          "allow": [
            "GET",
            "DELETE"
          ]
        }
      },
      "user": {
        "href": "https://fake/api/v1/users/oktaID0fTheFakeUser",
        "hints": {
          "allow": [
            "GET"
          ]
        }
      }
    }
  }
]';

}

sub Lemonldap::NG::Portal::Lib::Okta::issueFactor {
    return '{
    "factorResult": "CHALLENGE",
    "profile": {
        "phoneNumber": "+12532236986"
    },
    "_links": {
        "verify": {
            "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/smsszf1YNUtGWTx4j0g3/verify",
            "hints": {
                "allow": [
                    "POST"
                ]
            }
        },
        "factor": {
            "href": "https://fake/api/v1/users/oktaID0fTheFakeUser/factors/smsszf1YNUtGWTx4j0g3",
            "hints": {
                "allow": [
                    "GET",
                    "DELETE"
                ]
            }
        }
    }
}';

}

sub Lemonldap::NG::Portal::Lib::Okta::pollFactor {
    return '{
  "factorResult": "SUCCESS"
}';

}

sub Lemonldap::NG::Portal::Lib::Okta::verifyFactor {
    return '{
  "factorResult": "SUCCESS"
}';

}
