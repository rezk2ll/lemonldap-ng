#!/usr/bin/perl
#
# To use it, just insert your OW2 token in ~/.ow2-token

use LWP::UserAgent;
use JSON;

my $milestone = '2.0.0';
my @cat = ( 'Bug', 'Improvement', 'New Feature' );

open F, "$ENV{HOME}/.ow2-token" or die "Unable to get OW2 token ($!)";
my $token = join '',<F>;
close F;
$token =~ s/\s//sg or die "No token";

my $ua = LWP::UserAgent->new();

for (@cat) {
    my $res = $ua->get(
"https://gitlab.ow2.org/api/v4/projects/181/issues?label_name=$_&milestone_title=$milestone&state=all&private_token=$token"
    );
    print "### $_\n";
    $res = JSON::from_json( $res->content );
    for my $i (@$res) {
        print "$i->{iid} - $i->{title}\n";
    }
    print "\n";
}
