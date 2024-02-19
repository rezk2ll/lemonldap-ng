#!/usr/bin/perl -Ilemonldap-ng-manager/lib/ -Ilemonldap-ng-common/lib/ -w

use strict;
use Lemonldap::NG::Manager::Build::OpenApi;
use JSON qw/encode_json/;
use File::Temp qw/ tempfile /;

my $swagger_codegen_jar = $ENV{SWAGGER_CODEGEN};
if ( $swagger_codegen_jar and -f $swagger_codegen_jar ) {
    my ( $fh, $filename ) = tempfile( UNLINK => 1 );
    my $openapi_spec_json = JSON->new->utf8->pretty->canonical->encode(
        Lemonldap::NG::Manager::Build::OpenApi->openapi );

    #print STDERR $openapi_spec_json;
    print $fh $openapi_spec_json;
    close $fh;
    system(
        'java',               '-jar',
        $swagger_codegen_jar, 'generate',
        '-i',                 $filename,
        '-l',                 'html2',
        '-o',                 'doc/pages/manager-api/',
        '-c',                 'doc/sources/manager-api/config-codegen.json',
    );

}
else {
    die "Please run me with SWAGGER_CODEGEN=/path/to/swagger-codegen.jar";
}

