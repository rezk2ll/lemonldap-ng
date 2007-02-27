package Lemonldap::Portal::AccessPolicy;
	
use strict;
use warnings;
use Net::LDAP::Entry;
use Apache2::Const;
use Data::Dumper;
use Sys::Hostname;
use Lemonldap::Portal::Standard;
our $VERSION = '3.1.0';
	
	
sub default {
	

	my $self = shift;
	my $Entry=shift;
        my $Session=shift ;
	my $Org=shift ;
        my $Attribute = shift;
	my @Profil = $Entry->get_value($Attribute);
        foreach my $line (@Profil){
                my ($appl,$profile) = split (";",$line);
                $Session->{$Org}{lc($appl)} = $profile;
        }
}	
return 1;
