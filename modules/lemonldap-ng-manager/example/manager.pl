#!/usr/bin/perl

use Lemonldap::NG::Manager;

my $h=new Lemonldap::NG::Manager(
	{
		configStorage=>{
			type=>'File',
			dirName=>"/tmp/",
		},
		dhtmlXTreeImageLocation=> "/img/",
		# jsFile => /path/to/lemonldap-ng-manager.js,
	}
  ) or die "Impossible de démarrer";

$h->doall();
