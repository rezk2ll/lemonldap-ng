# Try to launch an LDAP server

if($ENV{LLNGTESTLDAP}) {
    eval { mkdir 't/testslapd/data' };
    system('/usr/sbin/slapadd -F t/testslapd/ -n 0 -l t/testslapd/slapd.ldif');
    system('/usr/sbin/slapadd -F t/testslapd/ -l t/testslapd/users.ldif');
    system('/usr/sbin/slapd -s 384 -h "ldap://127.0.0.1:19389/" -F t/testslapd');
}

sub stopLdapServer {
    if($ENV{LLNGTESTLDAP}) {
        open F, 't/testslapd/slapd.pid';
        my $pid = join '', <F>;
        system "kill $pid";
        system 'rm -rf t/testslapd/cn\=config*';
        system 'rm -rf t/testslapd/data';
    }
}

1;
