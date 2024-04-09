use warnings;

use Test::More;
use Test::Output;
use File::Path;
use JSON;

BEGIN {
    use_ok('Lemonldap::NG::Common::Session');
    use_ok('Lemonldap::NG::Common::CliSessions');
}

use File::Temp;
my $dir          = File::Temp::tempdir();
my $sessionsdir  = "$dir/sessions";
my $psessionsdir = "$dir/psessions";
mkdir $sessionsdir;
mkdir $psessionsdir;

my $session;

ok(
    $session = Lemonldap::NG::Common::Session->new( {
            force                => 1,
            hashStore            => 1,
            id                   => "123",
            storageModule        => 'Apache::Session::File',
            storageModuleOptions => { Directory => $sessionsdir },
            kind                 => "SSO",
            info                 => { aa => 1 },
        }
    ),
    'Create fixed session'
);

ok(
    $session = Lemonldap::NG::Common::Session->new( {
            hashStore            => 1,
            id                   => "123",
            storageModule        => 'Apache::Session::File',
            storageModuleOptions => { Directory => $sessionsdir },
            kind                 => "SSO",
            info                 => { aa => 1 },
        }
    ),
    'Recover fixed session'
);

ok(
    $session = Lemonldap::NG::Common::Session->new( {
            hashStore            => 1,
            id                   => undef,
            storageModule        => 'Apache::Session::File',
            storageModuleOptions => { Directory => $sessionsdir },
            kind                 => "SSO",
            info                 => { aa => 1 },
        }
    ),
    'Create session'
);

ok(
    $session = Lemonldap::NG::Common::Session->new( {
            hashStore            => 1,
            id                   => $session->id,
            storageModule        => 'Apache::Session::File',
            storageModuleOptions => { Directory => $sessionsdir },
            kind                 => "SSO",
            info                 => { aa => 1 },
        }
    ),
    'Recover session'
);

rmtree $dir;
done_testing();
