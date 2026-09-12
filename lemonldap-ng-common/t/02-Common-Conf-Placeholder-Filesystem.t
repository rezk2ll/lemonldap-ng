use warnings;
use strict;
use utf8;
use Test::More;
use Encode;
use File::Path qw(make_path);
use File::Temp;

BEGIN {
    delete $ENV{CREDENTIALS_DIRECTORY};
    use_ok('Lemonldap::NG::Common::Conf');
    use_ok('Lemonldap::NG::Common::Conf::Placeholder::Filesystem');
}

my $CLASS  = 'Lemonldap::NG::Common::Conf::Placeholder::Filesystem';
my $SECRET = 'Zz-VerySecretPassword-zZ';
my $dir    = File::Temp::tempdir( CLEANUP => 1 );

# Write $content (bytes) in the file $name of $dir
sub writeFile {
    my ( $name, $content ) = @_;
    open my $fh, '>:raw', "$dir/$name" or die "unable to write $name: $!";
    print $fh $content;
    close $fh;
    return "$dir/$name";
}

sub conf { return { filesystemPlaceholderDirectory => $dir, @_ } }

subtest 'Read a file' => sub {
    writeFile( 'managerPassword', "  $SECRET \n" );
    is( $CLASS->replace( conf(), 'managerPassword' ),
        $SECRET, 'Leading and trailing spaces are removed' );
    is( $CLASS->replace( conf(), ' managerPassword ' ),
        $SECRET, 'Spaces around the name are ignored' );
    is(
        $CLASS->replace(
            { filesystemPlaceholderDirectory => "$dir/" },
            'managerPassword'
        ),
        $SECRET,
        'Trailing slash in the directory is accepted'
    );

    writeFile( 'key.pem',
        "-----BEGIN KEY-----\nabc\ndef\n-----END KEY-----\n" );
    is(
        $CLASS->replace( conf(), 'key.pem' ),
        "-----BEGIN KEY-----\nabc\ndef\n-----END KEY-----",
        'Multi-line content is kept'
    );

    writeFile( 'utf8', Encode::encode( 'UTF-8', "pässwörd\n" ) );
    is( $CLASS->replace( conf(), 'utf8' ), 'pässwörd', 'UTF-8 is decoded' );

    # A secret mounted by Docker, Kubernetes or systemd is rotated in place
    writeFile( 'managerPassword', "rotated\n" );
    is( $CLASS->replace( conf(), 'managerPassword' ),
        'rotated', 'The file is read again at each call' );
    done_testing();
};

subtest 'Sub-directories and symbolic links' => sub {
    make_path("$dir/ldap");
    writeFile( 'ldap/password', 'in-a-sub-directory' );
    is( $CLASS->replace( conf(), 'ldap/password' ),
        'in-a-sub-directory', 'File in a sub-directory' );

  SKIP: {

        # Layout of a Kubernetes secret volume
        make_path("$dir/..2026_09_10");
        writeFile( '..2026_09_10/k8s', 'from-kubernetes' );
        skip 'symbolic links are not supported', 1
          unless ( symlink( '..2026_09_10', "$dir/..data" )
            and symlink( '..data/k8s', "$dir/k8s" ) );
        is( $CLASS->replace( conf(), 'k8s' ),
            'from-kubernetes', 'Symbolic links are followed' );
    }
    done_testing();
};

subtest 'CREDENTIALS_DIRECTORY' => sub {
    writeFile( 'managerPassword', $SECRET );
    local $ENV{CREDENTIALS_DIRECTORY} = $dir;
    is( $CLASS->replace( {}, 'managerPassword' ),
        $SECRET, 'CREDENTIALS_DIRECTORY is used by default' );

    my $other = File::Temp::tempdir( CLEANUP => 1 );
    eval {
        $CLASS->replace( { filesystemPlaceholderDirectory => $other },
            'managerPassword' );
    };
    like(
        $@,
        qr/unable to read/,
        "'filesystemPlaceholderDirectory' wins over CREDENTIALS_DIRECTORY"
    );
    done_testing();
};

subtest 'Errors' => sub {
    eval { $CLASS->replace( {}, 'managerPassword' ) };
    like(
        $@,
        qr/missing 'filesystemPlaceholderDirectory' option/,
        'Missing directory is reported'
    );
    unlike( $@, qr/ at .* line /, 'No perl file/line noise in error messages' );

    eval {
        $CLASS->replace(
            { filesystemPlaceholderDirectory => "$dir/nonexistent" },
            'managerPassword' );
    };
    like( $@, qr/directory .* does not exist/, 'Nonexistent directory' );

    for my $bad (
        '',          '../etc/passwd',  '/etc/passwd', '.hidden',
        'ldap/../x', 'ldap//password', 'ldap/',       'a b'
      )
    {
        eval { $CLASS->replace( conf(), $bad ) };
        like( $@, qr/bad file name/, "Name '$bad' is refused" );
    }

    eval { $CLASS->replace( conf(), 'missing' ) };
    like( $@, qr/unable to read '\Q$dir\E\/missing'/, 'Missing file' );

    eval { $CLASS->replace( conf(), 'ldap' ) };
    like( $@, qr/is not a regular file/, 'Directory is refused' );

    writeFile( 'empty', " \n" );
    eval { $CLASS->replace( conf(), 'empty' ) };
    like( $@, qr/is empty/, 'Empty file is refused' );

    writeFile( 'latin1', "p\xe4ss-$SECRET" );
    eval { $CLASS->replace( conf(), 'latin1' ) };
    like( $@, qr/is not a valid UTF-8 file/, 'Invalid UTF-8 is refused' );
    unlike( $@, qr/\Q$SECRET\E/, 'Content is not leaked' );
    done_testing();
};

subtest 'Fail-closed resolution in the configuration' => sub {
    writeFile( 'managerPassword',    $SECRET );
    writeFile( 'sessionsDbPassword', 'db-secret' );
    my $h = Lemonldap::NG::Common::Conf->new( {
            type                     => 'File',
            dirName                  => File::Temp::tempdir( CLEANUP => 1 ),
            configPlaceHolderModules => "FILE=$CLASS",
            filesystemPlaceholderDirectory => $dir,
        }
    );
    ok(
        $h->store( {
                cfgNum               => 1,
                managerPassword      => '%FILE:managerPassword%',
                globalStorageOptions =>
                  { Password => '%FILE:sessionsDbPassword%' },
            }
        ) == 1,
        'Conf is stored'
    ) or diag $Lemonldap::NG::Common::Conf::msg;

    my $cfg = $h->getConf( { cfgNum => 1 } );
    ok( $cfg, 'Configuration is accepted' )
      or diag $Lemonldap::NG::Common::Conf::msg;
    is( $cfg->{managerPassword}, $SECRET, 'Placeholder is resolved' );
    is( $cfg->{globalStorageOptions}->{Password},
        'db-secret', 'Placeholder inside a hash parameter is resolved' );

    my $raw = $h->getConf( { cfgNum => 1, raw => 1 } );
    is( $raw->{managerPassword},
        '%FILE:managerPassword%', 'Raw mode keeps the placeholder' );

    unlink "$dir/managerPassword";
    $Lemonldap::NG::Common::Conf::msg = '';
    is( $h->getConf( { cfgNum => 1 } ),
        undef, 'Configuration is refused when a file is missing' );
    like(
        $Lemonldap::NG::Common::Conf::msg,
qr/placeholder %FILE:managerPassword% could not be resolved: Filesystem: unable to read/,
        'Error is reported'
    );
    done_testing();
};

done_testing();
