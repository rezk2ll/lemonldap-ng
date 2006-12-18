#!/usr/bin/perl  -w
#use strict;

###################################################################
#

sub getStyle {
  if ($_[0] =~ /map/i) {
    return ("conf_style", 0);
  }
  if ($_[0] =~ /lectro/i) {
    return ("simpage", 1);
  }
  if ($_[0] =~ /golf/i) {
    return ("golf_style", 2);
  }
}

###################################################################
#

sub main {
  ($ch, $icheck) = getStyle("electro");
  print( "Resultat:\n" );
  print( "-- style = $ch\n" );
  print( "-- check = $icheck\n" );
}

###################################################################
#

main;

#
###################################################################
