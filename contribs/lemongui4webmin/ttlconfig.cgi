#!/usr/bin/perl  -w
#use strict;
use Template;
use  CGI;
use Data::Dumper;
require './lemonldap-lib.pl';


my $tt = Template->new( {# ABSOLUTE => 1,
    	  		   PREC_CHOMP =>1,
    		  	   POST_CHOMP =>1, } );

##########################################
# chargement des infos de la page        #
##########################################

if (! defined (CGI::param ("submitTtlConfig")) ) { 

  my $conf      = &getXmlPage( "ttlconfig" );
  my $filethtml = $conf->{template};
  my $title     = $text{ &dePourCent( $conf->{title} ) };
  my $_style    = CGI::param('style')||$config{Style};
  my $tabular   = [];
 
  $mode         = 'Expert' ;
  $tabular      = &getTab( $conf->{tabs}->{expert} );
  $tabular      = &polyGlotTab( $tabular, \%text );
  $tabular      = &ajustLink ($tabular,$mode,$_style);
  $flipflop     = 'Normal';
  $tab_active   = '2' ;

  $styl = $config{'Style'};

  my $composs   = &getAllComposants( $conf->{composants}->{expert} );
  $composs      = &polyGlotTab( $composs, \%text );

  my $xmlemon   = getXML( $config{'XML_file'} );
  my $chapter   = getChapterXML( $xmlemon, "cache" );
  
  &TransformVars( $composs, $chapter );

#  my $dump1 = Dumper( $composs );
#  my $dump2 = Dumper( $chapter );

  my $valab     = getRefValueInCompo( $composs, "LastModified" );
  my @fk        = keys( %{$chapter} );
  $valab->{ isChecked } = $chapter->{ $fk[0] }->{ LastModified } ? "CHECKED" : "";

  $vars= { style   => $styl,
    	 title   => $title, 
         mode    => $mode,
         css     => $_style,
         label   => $flipflop, 
     	 parent  => $0, 
         tab_about => $tabular,
	 langa   => \%text,
         composall => $composs
       }; 

  $vars->{style} = &getStyle($styl, $vars->{checked});

  print "Content-type: text/html\n";
  $tt->process($filethtml,$vars) || die $tt->error();

#  print("<BR><HR>Dump = $dump1 <HR><BR>");
#  print("<BR><HR>Dump = $dump2 <HR><BR>");

}  else { ## Traitement du "SUBMIT"
  ##########################################################

#   print "Content-type: text/html\n";
#   print( "\n" );
  my @lo =CGI::param();
#  my $l =Dumper(@lo);
#  print "$l";
#  print( "<BR>" );
  my $_style = CGI::param('style');
  my $mode = CGI::param('mode');
  my $old_clexml = CGI::param('_id');
  my $new_clexml = CGI::param('id');
  my $ttl = CGI::param('ConfigTtl') ;
  (my $lastm) = CGI::param('LastModified')=~ /on/i;
  my $path=CGI::param('ConfigIpcKey');
  my $hash = {} ;

  $hash->{'ConfigTtl'} = $ttl if $ttl;
  $hash->{'LastModified'} = $lastm if $lastm;
  $hash->{'ConfigFile'} = $path if $path;

  my $xmlemon   = getXML( $config{'XML_file'} );
  my $chapter   = getChapterXML( $xmlemon, "cache" );
#  my $l= Dumper ($chapter);
#  print "avant <BR>$l";
#  print( "<BR>" );
  delete $chapter->{$old_clexml};
#  print "old $old_clexml";
#  print( "<BR>" );
  $chapter->{$new_clexml}= $hash;                
#  $l= Dumper ($chapter);
#  print "apres <BR> $l";
  ######  ecriture par XMLOUT #############

  &writeXML( $xmlemon, $config{'XML_file'});

  #### affichage de la page ttconfig sur param 
 # $l= Dumper ($xmlemon);
 # print "final $l";
 &redirect( "index.cgi?mode=$mode&style=$_style" );
}
#
############ C FINI
