use Test::More;
use strict;

use IO::String;
use LWP::UserAgent;
use inc::LWP::Protocol::PSGI;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
    require 't/saml-lib.pm';
}

my $maintests = 1;
my $debug     = 'error';


# TODO

# Enable Auth Choice
# Enable SAML in Choice
# Register at least 2 SAML provider
# Launch authentication process
# Select SAML Choice tab
# Select an SAML IDP and conform
# -> expected result: SAML request sent

ok(1);

count($maintests);
clean_sessions();
done_testing( count() );
