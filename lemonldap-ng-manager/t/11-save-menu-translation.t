# Verify that translation keys of menu categories and applications are saved
# and checked

use warnings;
use Test::More;
use strict;
use JSON;
require 't/test-lib.pm';

my @confFiles = map { "$main::tmpdir/conf/lmConf-$_.json" } ( 1 .. 3 );

sub tree_with_translations {
    my ( $catKey, $appKey ) = @_;
    return get_conf_body_from_fixture(
        't/jsonfiles/02-base-tree-all-nodes-opened.json',
        sub {
            my @todo = @{ $_[0] };
            while ( my $node = shift @todo ) {
                if ( ( $node->{id} // '' ) eq 'applicationList' ) {
                    my $cat = $node->{nodes}->[0];
                    $cat->{data} = { translation => $catKey };
                    $cat->{nodes}->[0]->{data}->{translation} = $appKey;
                    return;
                }
                push @todo, @{ $node->{nodes} || [] };
            }
            die 'applicationList not found';
        }
    );
}

sub save {
    my ( $cfgNum, $len, $body ) = @_;
    my $res;
    ok(
        $res = &client->_post(
            '/confs/', "cfgNum=$cfgNum", $body, 'application/json', $len
        ),
        'Request succeed'
    );
    ok( $res->[0] == 200, 'Result code is 200' );
    return from_json( $res->[2]->[0] );
}

sub translationChanges {
    my ($resBody) = @_;
    return [
        map  { $_->{new} }
        grep { ( $_->{key} // '' ) =~ /translation/ }
          @{ $resBody->{details}->{__changes__} }
    ];
}

sub sampleCat {
    my ($file) = @_;
    open my $fh, '<', $file or die $!;
    my $conf = from_json( do { local $/; <$fh> } );
    return $conf->{applicationList}->{'0001-cat'};
}

subtest 'Reject bad translation keys' => sub {
    my $resBody = save( 1, tree_with_translations( 'my cat', 'myTest1' ) );
    is( $resBody->{result}, 0, 'Configuration rejected' )
      or diag explain $resBody;
    like(
        join( ' ',
            map { $_->{message} } @{ $resBody->{details}->{__errors__} } ),
        qr/Bad menu translation key\(s\): my cat/,
        'Error is reported'
    ) or diag explain $resBody;
    ok( !-e $confFiles[1], 'No configuration created' );
};

subtest 'Save translation keys' => sub {
    my $resBody = save( 1, tree_with_translations( 'mySampleCat', 'myTest1' ) );
    is( $resBody->{result}, 1, 'Configuration saved' )
      or diag explain $resBody;
    is_deeply(
        translationChanges($resBody),
        [ 'mySampleCat', 'myTest1' ],
        'Changes are reported'
    ) or diag explain $resBody;
    my $cat = sampleCat( $confFiles[1] );
    is( $cat->{options}->{translation},
        'mySampleCat', 'Category translation key is stored' );
    is( $cat->{'0002-app'}->{options}->{translation},
        'myTest1', 'Application translation key is stored' );
    ok(
        !exists $cat->{'0003-app'}->{options}->{translation},
        'No translation key for other applications'
    );
};

subtest 'Remove translation keys' => sub {
    my $resBody = save( 2, tree_with_translations( '', '' ) );
    is( $resBody->{result}, 1, 'Configuration saved' )
      or diag explain $resBody;
    is_deeply(
        translationChanges($resBody),
        [ undef, undef ],
        'Changes are reported'
    ) or diag explain $resBody;
    my $cat = sampleCat( $confFiles[2] );
    ok( !exists $cat->{options}, 'Category translation key is removed' );
    ok( !exists $cat->{'0002-app'}->{options}->{translation},
        'Application translation key is removed' );
};

unlink @confFiles[ 1, 2 ];
done_testing();
