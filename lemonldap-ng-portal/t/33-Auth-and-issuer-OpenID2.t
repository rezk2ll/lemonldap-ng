use Test::More;
use strict;
use IO::String;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
}

my $maintests = 4;
my $debug     = 'debug';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

SKIP: {
    eval { require Net::OpenID::Consumer; require Net::OpenID::Server; };
    if ($@) {
        skip 'Net::OpenID::* notfound', $maintests;
    }
    ok( $issuer = issuer(), 'Issuer portal' );
    $handlerOR{issuer} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;
    switch ('sp');

    ok( $sp = sp(), 'SP portal' );
    $handlerOR{sp} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;

    # Simple SP access
    my $res;
    ok(
        $res = $sp->_get(
            '/', accept => 'text/html',
        ),
        'Unauth SP request'
    );
    expectForm( $res, '#', undef );
    ok( $res->[2]->[0] =~ /name="openid_identifier"/, ' Found OpenID input' );

    my $query =
      'openid_identifier=http%3A%2F%2Fauth.idp.com%2Fopenidserver%2Fdwho';
    #ok(
    #    $res = $sp->_post(
    #        '/', IO::String->new($query), length => length($query),
    #    ),
    #    'Post OpenID identity'
    #);

    #print STDERR Dumper($res);
}

count($maintests);
clean_sessions();
done_testing( count() );

sub switch {
    my $type = shift;
    @Lemonldap::NG::Handler::Main::Reload::_onReload = @{
        $handlerOR{$type};
    };
}

no warnings 'redefine';

sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    ok( $req->uri =~ m#http://auth.idp.com(.*)#, ' Request from SP to IdP' );
    my $url = $1;
    my ($res);
    count(1);
    print STDERR Dumper($req);
    if ( $req->method =~ /^post$/i ) {
        my $s = $req->content;
        ok(
            $res = $issuer->_post(
                $url, IO::String->new($s),
                length => length($s),
                type   => $req->header('Content-Type'),
            ),
            '  Execute request'
        );
    }
    else {
        ok( $res = $issuer->_get( $url, ), '  Execute request' );
    }
    expectOK($res);
    ok( getHeader( $res, 'Content-Type' ) =~ m#^application/json#,
        '  Content is JSON' )
      or explain( $res->[1], 'Content-Type => application/json' );
    my $httpResp = HTTP::Response->new( $res->[0], 'OK' );

    while ( my $name = shift @{ $res->[1] } ) {
        $httpResp->header( $name, shift( @{ $res->[1] } ) );
    }
    $httpResp->content( join( '', @{ $res->[2] } ) );
    count(2);
    return $httpResp;
}

sub issuer {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel                 => $debug,
                templatesDir             => 'site/htdocs/static',
                domain                   => 'idp.com',
                portal                   => 'http://auth.idp.com',
                authentication           => 'Demo',
                userDB                   => 'Demo',
                issuerDBOpenIDActivation => 1,
            }
        }
    );
}

sub sp {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel       => $debug,
                domain         => 'sp.com',
                portal         => 'http://auth.sp.com',
                authentication => 'OpenID',
                userDB         => 'OpenID',
                openIdSecret   => 'qwerty',
            },
        }
    );
}
