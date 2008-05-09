package Lemonldap::NG::Handler::Status;

use strict;

our $status = {};

sub run {
    my( $localStorage, $localStorageOptions ) = ( shift, shift );
    #STDOUT->autoflush(1);
    my $refLocalStorage;
    eval "use $localStorage; \$refLocalStorage = new $localStorage(\$localStorageOptions);";
    die($@) if($@);
    $|=1;
    while(<STDIN>) {
	if(/^(\S+)\s+=>\s+(\S+)\s+(OK|REJECT|REDIRECT|LOGOUT)$/) {
	    my($user,$uri,$code) = ($1,$2,$3);
	    $status->{user}->{$user}->{$code}++;
	    $uri =~ s/^(.*?)\?.*$/$1/;
	    $status->{uri}->{$uri}->{$code}++;
	}
        elsif(/^STATUS$/) {
	    #print Dumper($status);
	    my $c;
	    while( my($user,$v) = each( %{ $status->{user} } ) ) {
		foreach(keys %$v) {
		    $c->{$_} += $v->{$_};
		}
	    }
	    use Data::Dumper; print Dumper($c);
	    my @t = $refLocalStorage->get_keys($localStorageOptions->{namespace});
	    print "Local Cache : " . @t . " objects\n";
	    print "\n";
	}
    }
}
1;
