#!/usr/bin/perl
#
# To use it, just insert your OW2 token in ~/.ow2-token
#
# This script downloads issues from gitlab.ow2.org and insert issues title in
# "changelog" file in a new version entry, grouped using tags: Bug,
# New feature, Improvement.
#
# Copyright: Xavier Guimard <x.guimard@free.fr>
# See COPYING for license

use LWP::UserAgent;
use JSON;

my $milestone = '2.0.15.1';
my @cat = ( 'Bug', 'New feature', 'Improvement', 'Template', 'WebServer Conf' );

open F, "$ENV{HOME}/.ow2-token" or die "Unable to get OW2 token ($!)";
my $token = join '', <F>;
close F;
$token =~ s/\s//sg or die "No token";

my $ua = LWP::UserAgent->new();

my $result = '';

for (@cat) {
    my $res = $ua->get(
"https://gitlab.ow2.org/api/v4/projects/181/issues?labels=$_&milestone=$milestone&state=all&scope=all&per_page=100&private_token=$token"
    );
    my $tmp .= "  * ${_}s:\n";
    $res = JSON::from_json( $res->content );
    my $add = 0;
    while ( my $i = pop @$res ) {
        $tmp .= "    * #$i->{iid}: $i->{title}\n";
        $add++;
    }
    $tmp    .= "\n";
    $result .= $tmp if $add;
}

`dch -b -c changelog -v $milestone '##CONTENT##';dch -c changelog -r --force-save-on-release '';cp changelog tmp.dch`;
open IN,  'tmp.dch';
open OUT, '>changelog';

$result =~ s/\n\n$//s;
while (<IN>) {
    chomp;
    s/.*##CONTENT##$/$result/;
    print OUT "$_\n";
}

unlink 'tmp.dch';

print STDERR "./changelog updated\n";
