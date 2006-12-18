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
my $message = 0;

my $dump1;

if (defined (CGI::param ('submitAddCluster')) ) {  ##  traitement d un nouveau node

  my $new_clexml = CGI::param('idn');
  if( !length($new_clexml)){
    $message = $text{ 'lab_error_8' };
  } else {

    my $location   = CGI::param('Locationn') ;
    my $address    = CGI::param('Addressn')  ;
    my $hash       = {} ;
    $hash->{'location'} = $location if $location;
    $hash->{'address'}  = $address  if $address;

    my $xmlemon   = getXML( $config{'XML_file'} );
    my $chapter   = getChapterXML( $xmlemon, 'cluster' );
    my $id        = CGI::param('id');   
    my $clust     = $chapter->{ $id } ;

    if( defined( $clust->{ 'node' }->{ $new_clexml } ) ){
      $message = $text{ 'lab_error_9' };
    }else {
      $clust->{ 'node' }->{ $new_clexml } = $hash;
      ######  ecriture par XMLOUT #############
      &writeXML( $xmlemon, $config{'XML_file'});
    }
  }
}

## vars pour affichage de caract. du node selectionné / supprimé
my $nodeID     = 0;
my $nodeSimple = 0;
my $nodeLoc    = 0;


if (defined (CGI::param ('RemoveNode')) ) {  ##  SUPPRESSION  d un  node
  my $clenode = CGI::param('idn');

  $nodeID     =  $clenode;
  $nodeSimple =  CGI::param('Addressn')  ;
  $nodeLoc    =  CGI::param('Locationn') ;
  
  my $xmlemon   = getXML( $config{'XML_file'} );
  my $chapter   = getChapterXML( $xmlemon, 'cluster' );
  my $id        = CGI::param('id');
  my $clust     = $chapter->{ $id } ;

  my @knodes    = keys( %{$clust->{'node'}} );

  $dump1 = Dumper( @knodes );
    
  delete( $clust->{ 'node' }->{ $clenode } );
   
  if( @knodes == 1 ){
    delete( $clust->{ 'node' } );
  }

  ######  ecriture par XMLOUT #############

  &writeXML( $xmlemon, $config{'XML_file'});
}


if (! defined (CGI::param ("submitCluster")) ) { 

  my $conf      = &getXmlPage( "cluster" );
  my $filethtml = $conf->{template};
  my $title     = $text{ &dePourCent( $conf->{title} ) };
  my $_style    = CGI::param('style')||$config{Style};
  my $tabular   = [];
 
  $mode         = 'Expert' ;
  $tabular      = &getTab( $conf->{tabs}->{expert} );
  $tabular      = &polyGlotTab( $tabular, \%text );
  $tabular      = &ajustLink ($tabular,$mode,$_style);
  $flipflop     = 'Normal';

  $styl = $config{'Style'};

  my $composs   = &getAllComposants( $conf->{composants}->{expert} );
  $composs      = &polyGlotTab( $composs, \%text );

  my $xmlemon   = getXML( $config{'XML_file'} );
  my $chapter   = getChapterXML( $xmlemon, "cluster" );
  
  my @f =  keys %{$chapter};  
  
  my $first =  $f[0];  

  &TransformVars( $composs, $chapter );
  ###############   I collect node info #####
  my @combonodes;
  if($chapter->{$first}->{node} ) {
    my $node  = $chapter->{$first}->{ "node" };
    my @nodes = keys( %{$node} );
    @nodes    = sort( @nodes );
                        
    for( @nodes ) {
      my $item = { "labOption" => $_, "idValue" => $_ };
      push( @combonodes, $_ );
    }
    # list of node
    # just label and add bouton
  } else {
    # just label and add bouton
  }

  my $flagShowRemo = 0;
  
  if( defined (CGI::param('listNodes') )){
    $nodeID     = CGI::param('listNodes');
    $nodeSimple = $chapter->{ $first }->{ 'node' }->{$nodeID}->{ 'address' };
    $nodeLoc    = $chapter->{ $first }->{ 'node' }->{$nodeID}->{ 'location' };
    $flagShowRemo= 1;
  }

  $vars= { style   => $styl,
    	 title     => $title, 
         mode      => $mode,
         css       => $_style,
         label     => $flipflop, 
     	 parent    => $0,
         tab_about => $tabular,
	 langa     => \%text,
         composall => $composs,
         combonodes => \@combonodes,
         message    => $message,
         nodeID     => $nodeID,    
         nodeSimple => $nodeSimple,
         nodeLoc    => $nodeLoc,
         flagShowRemo => $flagShowRemo
       };

  $vars->{style} = &getStyle($styl, $vars->{checked});

  
  print "Content-type: text/html\n";
  $tt->process($filethtml,$vars) || die $tt->error();

  print( "<HR> $dump1 <HR>" );
 
}  else { ## Traitement du "SUBMIT"
  ##########################################################

#   print "Content-type: text/html\n";
#   print( "\n" );
#  my @lo =CGI::param();
#  my $l =Dumper(@lo);
#  print "$l";
#  print( "<BR>" );
  my $_style     = CGI::param('style');
  my $mode       = CGI::param('mode');
  my $old_clexml = CGI::param('_id');
  my $new_clexml = CGI::param('id');
  my $location   = CGI::param('Location') ;
  my $address    = CGI::param('Address')  ;
  my $hash       = {} ;
  $hash->{'location'} = $location if $location;
  $hash->{'address'} = $address if $address;
  $hash->{'node'} = $node if $node;

  my $xmlemon   = getXML( $config{'XML_file'} );
  my $chapter   = getChapterXML( $xmlemon, "cluster" );
  my $l= Dumper ($chapter);
  delete $chapter->{$old_clexml};

  if($new_clexml ) {
    $xmlemon->{cluster}->{$new_clexml}= $hash;
  }
  else {
    delete $xmlemon->{cluster} ;
  }

  ######  ecriture par XMLOUT #############

  &writeXML( $xmlemon, $config{'XML_file'});

  #### affichage de la page ttconfig sur param 
  # $l= Dumper ($xmlemon);
  # print "final $l";
  &redirect( "index.cgi?mode=$mode&style=$_style" );
}
#
############ C FINI
