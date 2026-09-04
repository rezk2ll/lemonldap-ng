use Test::More;
use File::Find;

find(
    sub {
        return unless /\.js$/;

        # bwr/ holds vendored libraries, new/ the bundled beta manager: both
        # embed third-party code we do not control
        return if $File::Find::dir =~ m#/(?:bwr|new)(?:/|$)#;
        return unless -f;
        my $err;
        if ( open my $f, '<', $_ ) {
            grep( /console\.log/, <$f> )
              ? fail(
                "$File::Find::name uses console.log instead of console.<level>")
              : pass($File::Find::name);

        }
        else {
            fail "$File::Find::name: $!";
        }
    },
    qw(site/js-src site/htdocs/static)
);

done_testing();
