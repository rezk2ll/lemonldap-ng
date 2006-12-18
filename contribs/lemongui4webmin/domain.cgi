#!/usr/bin/perl  -w
#use strict;
use Template;
use  CGI;
use Data::Dumper;
require './lemonldap-lib.pl';


my $tt = Template->new( {# ABSOLUTE => 1,
    	  		   PREC_CHOMP =>1,
    		  	   POST_CHOMP =>1, } );


## 
## PAS DE NOUVEAU DOMAINE NOMMES "ADD DOMAIN" OU NON NOMMES
##------------------------------------------------------------------------------------
my $message = 0;

my $flagSUBMIT = CGI::param('submitDomain') ;
if( defined( $flagSUBMIT ) ) {
  if( CGI::param( 'idDomain' ) eq $text{ lab_26 } ){
    $message    = 'ERROR: \"\" ' . $text{ lab_26 } . ' \"\" ' . $text{lab_error_4};
    $flagSUBMIT = undef;
  }
  if( !length( CGI::param( 'idDomain' ) ) ){
    $message    = 'ERROR: ' . ' ' . $text{lab_error_5};
    $flagSUBMIT = undef;
  }
}
                           

##########################################
# chargement des infos de la page        #
##########################################

if (! defined ($flagSUBMIT) ) {

  my $conf      = &getXmlPage( "domain" );
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

  $styl = $config{'Style'};

  if( defined (CGI::param ("editHandlers")) )  {
    my $dom    = CGI::param('cbDomain');
    my $handle = CGI::param('listHandlers');
    &redirect( "handlers_0.cgi?mode=$mode&style=$_style&Domain=$dom&SelHandler=$handle" );    
    exit(0);
  }

  $tabular = &polyGlotTab( $tabular, \%text );
  $tabular = &ajustLink ($tabular,$mode,$_style);
  
  $composs      = &polyGlotTab( $composs, \%text );

  my $xmlemon   = getXML( $config{'XML_file'} );

  my $sesserv   = getChapterXML( $xmlemon, "session" );
  if( !$sesserv ){
    &redirect( "/lemongui4webmin/session.cgi?mode=$mode&amp;style=$styl" );
    exit(); 
  }
  
  my $chapter   = getChapterXML( $xmlemon, "domain" );
  
  #my $flagShowEditHandler = ( keys( %{chapter} ) ) ? 1 : 0;

  my @sessIDs   = keys( %{$sesserv} );

  my @comboSessions;

  for( @sessIDs ){
    my $item = { "labOption" => $_, "idValue" => $_ };
    push( @comboSessions, $item );
  } 

  ## combo box domaines
  my $combo_domains; 
 
  ##
  ## sélection de la bonne ligne dans la comboBox des domains et ajout de l'item "ADD NEW"
  ## 
  my $firstL = &keyToVal( $chapter, $combo_domains );
  my $addnew = { "labOption" => $text{ lab_26 }, "idValue" => $text{ lab_26 } };
  push( @{$combo_domains}, $addnew );

  #
  ########################################## TEST POUR CHANGEMENT de domaine
  #

  my $cbd = CGI::param( cbDomain );
  if( !$cbd ){
    $cbd = $firstL; 
  }
  if( defined( CGI::param( 'ledomaine' ) ) ){
    $cbd = CGI::param( 'ledomaine' );
  }
  

  my $sessSelected = $chapter->{ $cbd }->{ 'SessionStore' };

  my %chapterX = ( 'xxxx', $chapter->{ $cbd } ); 
  &TransformVars( $composs, \%chapterX );

  ## IPCheck ???
  ##----------------------
  my $valab = getRefValueInCompo( $composs, 'IPCheck' );
#  my $dump1;
  $valab->{ isChecked } = $chapterX{'xxxx'}->{ 'IPCheck' } ? "CHECKED" : "";

  #
  ######## DELETE HANDLER
  #
  if( defined( CGI::param('DeleteHandler'))){
   my $allHandlersChapters = $chapter->{ $cbd }->{ 'handler' };
   my $selectedHand        = CGI::param('listHandlers');
   
    if( &OkToChange( $allHandlersChapters, $selectedHand, $message )){
      ## DELETE SELECTED HANDLER
      ##-------------------------
      delete( $chapter->{ $cbd }->{ 'handler' }->{ $selectedHand } );
      &writeXML( $xmlemon, $config{'XML_file'});
    }
  }

  #
  ######## DELETE DOMAIN
  #

  my $flagShowEditHandler = 1;
    
  if( defined( CGI::param('DeleteDomain'))){
    my $allHandlersChapters = $chapter->{ $cbd }->{ 'handler' };
    if( $allHandlersChapters ){
      $message = 'ERROR: '. $cbd . ' ' . $text{ 'lab_error_6' };
    } else {
      delete( $chapter->{ $cbd } );

      ## reste t il des domaines ???
      ##-----------------------------
      my @kdoms = keys( %{$chapter} );
      if( !@kdoms ){
        delete( $xmlemon->{'domain'} );
        $flagShowEditHandler = 0;
      }
      
      &writeXML( $xmlemon, $config{'XML_file'});
      $combo_domains = undef;
      $firstL = &keyToVal( $chapter, $combo_domains );
      my $addnew = { "labOption" => $text{ lab_26 }, "idValue" => $text{ lab_26 } };
      push( @{$combo_domains}, $addnew );
    }
  }
  
  ## RECUP HANDLERS ASSOC WITH DOMAIN
  my $handlers = $chapter->{ $cbd }->{ 'handler' };
  my @handkeys = keys( %{$handlers} );
  @handkeys    = sort( @handkeys );
  
  my @listHandlers;
 
  for( @handkeys ){
    my $item = { "labOption" => $_, "idValue" => $_ };
    push( @listHandlers, $item );
  }
  
  if( $cbd eq $text{ lab_26 }  || !$cbd){
    $flagShowEditHandler = 0;
  }

  #$dump1 = $cbd;

  #
  #######  VARIABLES PASSES EN PARAMETRE AU TEMPLATE

  $vars= { style                => $styl,
           checked              => $check,
    	   title                => $title,
           mode                 => $mode,
	   cgi                  => 'domain.cgi',
           css                  => $_style,
           label                => $flipflop, 
     	   parent               => $0, 
           tab_session          => $tabular,
	   langa                => \%text,
           composall            => $composs,
           combo_domain         => $combo_domains,
           option_selected      => $cbd,
           label_combo          => $text{ 'lab_17' },
           label_comboSess      => $text{ 'session_server' },
           selected_session     => $sessSelected,
           combo_sessions       => \@comboSessions,
           list_handlers        => \@listHandlers,
           flag_ShowEditHandler => $flagShowEditHandler,
           message              => $message,
           lab_56               => $text{ 'lab_56' },
           lab_57               => $text{ 'lab_57' }
};

  $vars->{style} = &getStyle($styl, $vars->{checked});

  print "Content-type: text/html\n";
  $tt->process($filethtml,$vars) || die $tt->error();

  ## print("<BR><HR>Dump1 ---> $dump1 <HR><BR>");
  ## print("<BR><HR>Dump = $dump2 <HR><BR>");

}  else { ## Traitement du "SUBMIT"
  ##########################################################
=pod
  print "Content-type: text/html\n";
  print( "\n" );


  my @lo =CGI::param();
  my $l =Dumper(@lo);
  print "$l";
  print( "<BR><hr><BR>" );
  for( @lo ){
    my $loc   = CGI::param( $_ );
    print("$_ --> $loc //");
  }
=cut  

  my $_style = CGI::param('style');
  my $mode   = CGI::param('mode');
  my $dom    = CGI::param( 'idDomain' );

  my $xmlemon = getXML( $config{'XML_file'} );
  my $chapter = getChapterXML( $xmlemon, "domain" );
  if( !$chapter ){
    $xmlemon->{ 'domain' }->{ $dom }->{ 'Cookie' } = CGI::param( 'Cookie' );
    $chapter = $xmlemon->{ 'domain' }->{ $dom };
  } else {
    $chapter = $chapter->{ $dom };
    if( !$chapter ){
      $xmlemon->{ 'domain' }->{ $dom }->{ 'Cookie' } = CGI::param( 'Cookie' );
      $chapter = $xmlemon->{ 'domain' }->{ $dom };
    }
  }

  $chapter->{ 'Cookie' }  = CGI::param( 'Cookie' );
  if( !length( $chapter->{ 'Cookie' } ) ){
    $chapter->{ 'Cookie' } = "lemonldap";
  }
  $chapter->{ 'ldap_branch_people' } = CGI::param( 'ldap_branch_people' );
  $chapter->{ 'Portal' }             = CGI::param( 'Portal' );
  $chapter->{ 'SessionStore' }       = CGI::param( 'cbSessions' );
  $chapter->{ 'ldap_server' }        = CGI::param( 'ldap_server' );  
  $chapter->{ 'ldap_port' }          = CGI::param( 'ldap_port' );
  if( !length( $chapter->{ 'ldap_port' } ) ){
    $chapter->{ 'ldap_port' } = "389";
  }
  $chapter->{ 'DnManager' }          = CGI::param( 'DnManager' );
  $chapter->{ 'passwordManager' }    = CGI::param( 'passwordManager' );

  if( defined( CGI::param('slavecda') ))	{
    $chapter->{ 'slavecda' } = CGI::param( 'slavecda' );
  }

  $chapter->{ 'IPCheck' } = defined( CGI::param('IPCheck') ) ? '1' : '0';

  &writeXML( $xmlemon, $config{'XML_file'});    

#  my $dump1 = Dumper( $chapter );
#  my $dump2 = Dumper( @comboSessions ); 
  
#  print("<BR><HR>Dump1 = $dump1 <HR><BR>");
#  print("<BR><HR>Dump = $dump2 <HR><BR>");

  &redirect( "domain.cgi?mode=$mode&style=$_style&cbDomain=$dom" );
}
#
############ C FINI
