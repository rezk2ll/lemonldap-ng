#!/usr/bin/perl  -w
#use strict;

###################################################################
#

sub getStyle {
  my $style = $_[0];

  if ($style =~ /map/i) {
    $_[1] = 0;
    return "conf_style";
  }
  if ($style =~ /lectro/i) {
    $_[1] = 1;
    return "simpage";
  }
  if ($style =~ /golf/i) {
    $_[1] = 2;
    return "golf_style";
  }
}

###################################################################
#

sub main {
  my $icheck = -1;
  $ch = getStyle("electro", $icheck);
  print( "Resultat:\n" );
  print( "-- style = $ch\n" );
  print( "-- check = $icheck\n" );
}

###################################################################
#

main;

#
###################################################################
