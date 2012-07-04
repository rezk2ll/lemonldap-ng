use Test::More tests => 3;

BEGIN {
  use_ok("Lemonldap::NG::Portal::Simple");
}

# build Lemonldap::NG::Portal::Simple object 
my $p = Lemonldap::NG::Portal::Simple->new(
 {
  globalStorage    => 'Apache::Session::File',
  domain	   => 'example.com',
  error		   => 0,
  applicationList  => {},
  locationRules    => {
    'test.example.com' => {
        'default'  => "deny",
	'^/ok'     => '$uid eq "kharec"',
	'^/nok'   => '$uid eq "toto"',
    },
  },
  cfgNum      => 42,
  sessionInfo => { uid => "kharec"},

  }
);

## Overload captcha_output and captcha_data
mkdir "./tmp";
$p->{captcha_output} = "./tmp/output";
$p->{captcha_data} = "./tmp/data";
mkdir $p->{captcha_output};
mkdir $p->{captcha_data};

ok(ref($p) eq "Lemonldap::NG::Portal::Simple");

# try to init a captcha
ok($p->initCaptcha());

END {
  system("rm -rf ./tmp");
}

