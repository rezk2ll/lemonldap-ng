use Test::More;
use strict;
use IO::String;
use MIME::Base64;

BEGIN {
    require 't/test-lib.pm';
}

my $maintests = 1;
my $debug     = 'error';
my ( $issuer, $sp, $res );
my %handlerOR = ( issuer => [], sp => [] );

SKIP: {
    eval "use AuthCAS";
    if ($@) {
        skip 'AuthCAS not found', $maintests;
    }

    #ok( $issuer = issuer(), 'Issuer portal' );
    #$handlerOR{issuer} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;
    switch ('sp');

    ok( $sp = sp(), 'SP portal' );
    $handlerOR{sp} = \@Lemonldap::NG::Handler::Main::Reload::_onReload;

}

count($maintests);
clean_sessions();
done_testing( count() );

# Redefine LWP methods for tests
no warnings 'redefine';
sub LWP::UserAgent::request {
    my ( $self, $req ) = @_;
    ok( $req->uri =~ m#http://auth.sp.com(.*)#, 'Request from SP to IdP' );
    my $url = $1;
    my $res;
    my $s = $req->content;
    ok(
        $res = $sp->_post(
            $url, IO::String->new($s),
            length => length($s),
            type   => 'application/xml',
        ),
        'Execute request'
    );
    ok( ( $res->[0] == 200 or $res->[0] == 400 ), 'Response is 200 or 400' )
      or explain( $res->[0], "200 or 400" );
    ok( $issuer->getHeader( $res, 'Content-Type' ) =~ m#^application/xml#,
        'Content is XML' )
      or explain( $res->[1], 'Content-Type => application/xml' );
    my $httpResp = HTTP::Response->new( $res->[0], 'OK' );

    while ( my $name = shift @{ $res->[1] } ) {
        $httpResp->header( $name, shift( @{ $res->[1] } ) );
    }
    $httpResp->content( join( '', @{ $res->[2] } ) );
    count(4);
    return $httpResp;
}

sub switch {
    my $type = shift;
    @Lemonldap::NG::Handler::Main::Reload::_onReload = @{
        $handlerOR{$type};
    };
}

sub issuer {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel               => $debug,
                templatesDir           => 'site/htdocs/static',
                domain                 => 'idp.com',
                portal                 => 'http://auth.idp.com',
                authentication         => 'Demo',
                userDB                 => 'Demo',
                issuerDBCASActivation  => 1,
                casAttr                => 'uid',
                casAttributes          => { cn => 'cn', uid => 'uid', },
                casAccessControlPolicy => 'none',
            }
        }
    );
}

sub sp {
    return LLNG::Manager::Test->new(
        {
            ini => {
                logLevel              => $debug,
                domain                => 'sp.com',
                portal                => 'http://auth.sp.com',
                authentication        => 'CAS',
                userDB                => 'Null',
                issuerDBCASActivation => 0,
                CASurl                => 'http://auth.idp.com/cas/',
                CASCAFile             => 't/caFile.pem',
            },
        }
    );
}
