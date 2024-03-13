use warnings;

use Apache::Session::File;
use Cache::FileCache;
use File::Find;
use File::Path;
use File::Temp;
use JSON;
use Test::More;

BEGIN {
    use_ok('Lemonldap::NG::Common::Apache::Session');
    use_ok('Lemonldap::NG::Common::Session');
}

my $dir         = File::Temp::tempdir();
my $sessionsdir = "$dir/sessions";
my $cachedir    = "$dir/cache";

mkdir $sessionsdir;
mkdir "$sessionsdir/lock";
mkdir $cachedir;

my %session;

my $cacheOpts = {
    namespace  => 'llng',
    cache_root => $cachedir,
};

my $args = {
    localStorage        => 'Cache::FileCache',
    localStorageOptions => $cacheOpts,
    backend             => 'Apache::Session::File',
    Directory           => $sessionsdir,
    LockDirectory       => "$sessionsdir/lock",
};

ok( tie( %session, 'Lemonldap::NG::Common::Apache::Session', undef, $args ),
    'Create session' );
my $id;
ok( $id = $session{_session_id}, "Get session id $id" );

$session{aa} = 'bb';
untie %session;

my $cache = Cache::FileCache->new($cacheOpts);
my $cacheData;

# Cache corruption
$cache->set( $id, '{"a":k' );
ok( tie( %session, 'Lemonldap::NG::Common::Apache::Session', $id, $args ),
    'Get session' );
ok( $session{aa} eq 'bb', 'Session is restored' );

$session{bb} = 'cc';
untie %session;

# Cache deletion
rmtree $cachedir;
mkdir $cachedir;
chmod 0555, $cachedir;

ok( tie( %session, 'Lemonldap::NG::Common::Apache::Session', $id, $args ), 'Get session' );
ok( $session{bb} eq 'cc', 'Session is restored' );
untie %session;

system('find',$cachedir,'-type','f');

rmtree $dir;
done_testing();
