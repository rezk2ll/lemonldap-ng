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

if (! defined (CGI::param ("submitSession")) ) { 
  
  my $conf      = &getXmlPage( "session" );
  my $filethtml = $conf->{template};
  my $title     = $text{ &dePourCent( $conf->{title} ) };
  my $_style    = CGI::param('style')||$config{Style};
  my $tabular   = [];
  my $composs;
  my $mode;

  my $refTimeOut;
 
  if (CGI::param('mode') =~ /pert/) { # mode expert beaucoups plus d option 
    $mode='Expert' ;
    $tabular = &getTab( $conf->{tabs}->{expert} );
    $flipflop= 'Normal';
    $composs   = &getAllComposants( $conf->{composants}->{expert} );
    $refTimeOut = &getRefValueInCompo( $composs, 'idTimeOut' );
  } else { 
    $mode ='Normal';
    $tabular = &getTab( $conf->{tabs}->{normal} );
    $flipflop= 'Expert';
    $composs   = &getAllComposants( $conf->{composants}->{normal} );
  } 

  $tabular = &polyGlotTab( $tabular, \%text );
  $tabular = &ajustLink ($tabular,$mode,$_style);
  $styl = $config{'Style'};
  
  $composs      = &polyGlotTab( $composs, \%text );

  my $xmlemon   = getXML( $config{'XML_file'} );
  my $chapter   = getChapterXML( $xmlemon, "session" );

  #############################################################################
  #
  #  TEST SUR BOUTONS " ADD / REMOVE / APPLY " SERVERS / LOCAL / TIMEOUT 
  #                      ( mode normal/expert )
  #
  #############################################################################
  my $flagADD   = ( CGI::param( bAdd ) || CGI::param( bAddLoc ) );
  my $flagREMO  = ( CGI::param( bRemove ) || CGI::param( bRemoveLoc ) );
  my $flagAPPLY_TO = ( CGI::param( bApplyTimeOut ));
  my $sess; 

  my $chactif;
  my $chaux; 
  my $idEditServ;
  my $idEditPort;
  my $laListeServers;

  #############################################################################
  #
  #  CHARGEMENT DES VARIABLES SUIVANT LE PARAGRAPHE XML A MODIFIER
  #
  #############################################################################
  if( CGI::param( bAdd ) || CGI::param( bRemove ) ){
    $chactif = 'servers';
    $chaux   = 'local';
    $idEditServ = 'idServer';
    $idEditPort = 'idPort';
    $laListeServers = 'listServers';
  } elsif ( CGI::param( bAddLoc ) || CGI::param( bRemoveLoc ) ){
    $chactif = 'local';
    $chaux   = 'servers';
    $idEditServ = 'idServerLoc';
    $idEditPort = 'idPortLoc';
    $laListeServers = 'listServersLoc';
  } 
  if( $flagAPPLY_TO ){
    #############################################################################
    #
    # MAJ du paragraphe timeout 
    #
    #############################################################################
    my $timou = CGI::param( 'idTimeOut' );
    $sess  = CGI::param( idSession ); 
    my $ch;

    if( $chapter ){
      $ch = $chapter->{ $sess }->{ SessionParams } ; 
    }
    my %ches = eval( $ch );

    if( !$timou ){
      delete( $ches{ 'timeout' } );
    }else{
      $ches{ 'timeout' } = $timou;
    }

    $Data::Dumper::Terse = 1;
    $Data::Dumper::Purity = 1;
    $Data::Dumper::Indent = 2;
    my $ligne = Dumper( \%ches );
    my $lg    = length( $ligne );
    substr( $ligne, 0, 1 ) = '(';
    substr( $ligne, $lg-2, 1 ) = ')';
  
    if($chapter)  {
      $chapter->{ $sess }->{ SessionParams } = $ligne;  
    } else {
      $xmlemon->{session}->{$sess}->{SessionParams} = $ligne ;
    }  
    &writeXML( $xmlemon, $config{'XML_file'});    
    $chapter   = getChapterXML( $xmlemon, "session" );

  } elsif( $flagADD ){
    #############################################################################
    #
    # MAJ (ADD) du paragraphe servers OU local suivant le contenu $chactif et $chaux
    #
    #############################################################################
    my $nserv = CGI::param( $idEditServ );
    my $nport = CGI::param( $idEditPort );

    $sess  = CGI::param( idSession ); 
 
    my $ch;
    if( $chapter ){
      $ch = $chapter->{ $sess }->{ SessionParams } ; 
    }
    my %ches = eval( $ch );

    my @tch  = @{$ches{ $chactif }};
    push( @tch, ($nserv.":".$nport) );
    my %h    = ( $chactif => \@tch );

    if( exists( $ches{ $chaux } )) {
      $h{ $chaux } =  $ches{ $chaux };
    }
    if( exists( $ches{ 'timeout' } )) {
      $h{ 'timeout' } =  $ches{ 'timeout' };
    }
    
    $Data::Dumper::Terse = 1;
    $Data::Dumper::Purity = 1;
    $Data::Dumper::Indent = 2;
    my $ligne = Dumper( \%h );
    my $lg    = length( $ligne );
    substr( $ligne, 0, 1 ) = '(';
    substr( $ligne, $lg-2, 1 ) = ')';
  
    if($chapter)  {
      $chapter->{ $sess }->{ SessionParams } = $ligne;  
    } else {
      $xmlemon->{session}->{$sess}->{SessionParams} = $ligne ;
    }  
    &writeXML( $xmlemon, $config{'XML_file'});    
    $chapter   = getChapterXML( $xmlemon, "session" );

  }elsif( $flagREMO ){
    #############################################################################
    #
    # MAJ (REMOVE) du paragraphe servers OU local suivant le contenu $chactif et $chaux
    #
    #############################################################################
    my $serpor = CGI::param( $laListeServers ); 

    my $sess  = CGI::param( idSession ); 
    my $ch   = $chapter->{ $sess }->{ SessionParams };
    my %ches = eval( $ch );
    my @tch  = @{$ches{ $chactif }};
    my @NT;
    for( @tch ){
      if( !($_ eq $serpor)){
        push( @NT, $_ );
      }
    }
    if( !@NT ){
      delete( $chapter->{ $sess } );
      if( !keys( %{$xmlemon->{session}} )){
        delete( $xmlemon->{session} ); 
      }
    } else {
      my %h    = ( $chactif => \@NT );
      if( exists( $ches{ $chaux } )) {
        $h{ $chaux } =  $ches{ $chaux };
      }
      if( exists( $ches{ 'timeout' } )) {
        $h{ 'timeout' } =  $ches{ 'timeout' };
      }

      $Data::Dumper::Terse = 1;
      $Data::Dumper::Purity = 1;
      my $ligne = Dumper( \%h );
      my $lg    = length( $ligne );
      substr( $ligne, 0, 1 ) = '(';
      substr( $ligne, $lg-2, 1 ) = ')';
      $chapter->{ $sess }->{ SessionParams } = $ligne;
    }

    &writeXML( $xmlemon, $config{'XML_file'});    
  }
  #
  ################################################################### FIN DE TEST ET MAJ
  my $combo_sessions; 
 
  ##
  ## sélection de la bonne ligne dans la comboBox des sessions et ajout de l'item "ADD NEW"
  ## 
  my $firstL = &keyToVal( $chapter, $combo_sessions );
  my $addnew = { "labOption" => $text{ lab_11 }, "idValue" => $text{ lab_11 } };
  push( @{$combo_sessions}, $addnew );

  #
  ########################################## TEST POUR CHANGEMENT de session
  #
  my $cbs = CGI::param( cbSession );
  if( !$cbs ){
    $cbs = $firstL; 
  }
  if( $flagADD ){
    $cbs = $sess;
  }
  my $line = $chapter->{ $cbs }->{SessionParams};
  my %lines = eval( $line );

  my @tabser = @{$lines{ 'servers' }};    # liste des serveurs "standard"
  my @tablocser = @{$lines{ 'local' }};   # liste des serveurs "locaux"

  $refTimeOut->{ 'defValue' } = $lines{ 'timeout' };  

  #
  #######  VARIABLES PASSES EN PARAMETRE AU TEMPLATE

  $vars= { style   => $styl,
           checked => $check,
    	   title   => $title,  
           mode    => $mode,
	   cgi     => 'session.cgi',
           css     => $_style,
           label   => $flipflop, 
     	   parent  => $0, 
           tab_session => $tabular,
	   langa   => \%text,
           composall => $composs,
           combo_session => $combo_sessions,
           list_servers => \@tabser,
           list_locservers => \@tablocser,
           option_selected => $cbs,
           label_combo => $text{ lab_10 }
       }; 

  $vars->{style} = &getStyle($styl, $vars->{checked});

  print "Content-type: text/html\n";
  $tt->process($filethtml,$vars) || die $tt->error();

}  else { ## Traitement du "SUBMIT"
  ##########################################################

  my $_style = CGI::param('style');
  my $mode = CGI::param('mode');

  &redirect( "index.cgi?mode=$mode&style=$_style" );
}
#
############ C FINI
