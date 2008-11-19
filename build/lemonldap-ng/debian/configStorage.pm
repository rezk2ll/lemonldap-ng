#!/usr/bin/perl

package Lemonldap::NG::Conf;

our $configStorage;

BEGIN {
    open F, '/etc/lemonldap-ng/storage.conf' or die "/etc/lemonldap-ng/storage.conf: $!";
    while(<F>) {
        next if(/^\s*$/ or /^\s*#/);
        chomp;
        s/\r//g;
        /^\s*([\w]+)(?:\s*[:=]\s*|\s+)(["']?)([\S].*[\S])\2\s*$/ or next;
        my $k = $1;
        $configStorage->{$k} = $3;
        if($configStorage->{$k} =~ /^([{\[]).*[}\]]$/) {
            eval "\$configStorage->{$k} = $configStorage->{$k}";
        }
    }
    close F;
}
1;
