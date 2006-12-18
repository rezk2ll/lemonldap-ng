#!/usr/bin/perl  -w
#use strict;
use Template;
use  CGI;
use Data::Dumper;
require './lemonldap-lib.pl';


my $dump1; 
my $dump2;


#---------------------------------------------------------------------
#  SUUPRIME DES COMPOSANTS ISSUS DU guiconfig.xml POUR ASSISTANT
#---------------------------------------------------------------------

sub  CleanComposants {
  my $compos  = $_[0];
  my @keep    = @{$_[1]};
  my $newcomp;

  $dump2 = join(',', @keep);
  
  for( @keep ){
    my $item = $_;
    
    for( @{$compos} ){
      my $comp = $_;
      if( $comp->{ 'id_input' } eq $item ){
        push( @{$newcomp}, $comp );
      }
    }  
  }
  $_[0] = $newcomp;
}


my $message = 0;

my $tt = Template->new( {# ABSOLUTE => 1,
    	  		   PREC_CHOMP =>1,
    		  	   POST_CHOMP =>1, } );



## ATTENTION A CONTROLER SI TYPE HANDLER == COMBINED --->  MotifOut  PAS VIDE !!!!!
## PAS DE NOUVEAU HANDLER NOMMES "ADD HANDLER" OU NON NOMMES
##------------------------------------------------------------------------------------
my $flagSUBMIT = CGI::param('submitHandlers_0') ;
if( defined( $flagSUBMIT ) ) {
  if( CGI::param( 'selTypeHandler' ) eq 'CombinedType' ){
    if( !length( CGI::param( 'MotifOut' ) ) ){
      $message    = 'ERROR: ' . $text{lab_error_0};
      $flagSUBMIT = undef;
    }
  }
  if( CGI::param( 'idHandler' ) eq $text{ lab_55 } ){
    $message    = 'ERROR: \"\" ' . $text{ lab_55 } . ' \"\" ' . $text{lab_error_1};
    $flagSUBMIT = undef;
  }
  if( !length( CGI::param( 'idHandler' ) ) ){
    $message    = 'ERROR: ' . ' ' . $text{lab_error_3};
    $flagSUBMIT = undef;
  }
  if( defined( CGI::param( 'IPAdress' )) ){
    if( !length( CGI::param( 'IPAdress' )) ){
      $message    = 'ERROR: ' . ' ' . $text{lab_error_11};
      $flagSUBMIT = undef;
    }
  }
}


##########################################                                                                                     
# chargement des infos de la page        #
##########################################

if ( !defined( $flagSUBMIT)) {

  my $conf      = &getXmlPage( "handlers_0" );
  my $filethtml = $conf->{template};

  my $selectedHand;
  my $domActif;
  my $flagSameHandler = 0;
  my $tabular   = [];

  if ( defined (CGI::param ("Domain")) ) { 
    $domActif  = CGI::param('Domain');
    $selectedHand = CGI::param('SelHandler');
  } else {
    $domActif     = CGI::param('idDomain');
    $selectedHand = CGI::param('cbHandlers');
    
    if( $selectedHand eq CGI::param('ExHandler')) {
      $flagSameHandler = 1; ## même handler en ré entrant
    }
  }

  my $title     = $text{ &dePourCent( $conf->{title} ) } . " / " . $domActif;

  my $_style    = CGI::param('style')||$config{Style};

  my $composs;
  my $mode;

  if (CGI::param('mode') =~ /pert/) { # mode expert beaucoups plus d option 
    $mode     ='Expert' ;
    $composs  = &getAllComposants( $conf->{'composants'}->{'expert'} );
    $tabular  = &getTab( $conf->{'tabs'}->{'expert'} );
  } else {
    $mode     ='Normal';
    $composs  = &getAllComposants( $conf->{'composants'}->{'normal'} );
    $tabular  = &getTab( $conf->{'tabs'}->{'normal'} );
  }

  $styl = $config{'Style'};
  $tabular = &polyGlotTab( $tabular, \%text );
  $tabular = &ajustLink ($tabular,$mode,$_style,$domActif);
  $composs      = &polyGlotTab( $composs, \%text );

  my $xmlemon   = getXML( $config{"XML_file"} );
  my $chapter   = getChapterXML( $xmlemon, "domain" );

  my $handlers = $chapter->{ $domActif }->{ "handler" };
  my @handkeys = keys( %{$handlers} );
  @handkeys    = sort( @handkeys );

  my @comboHandlers;
 
  for( @handkeys ){
    my $item = { "labOption" => $_, "idValue" => $_ };
    push( @comboHandlers, $item );
  }

  my $item = { "labOption" => $text{ lab_55 }, "idValue" => $text{ lab_55 } };
  push( @comboHandlers, $item );
  
  if( !$selectedHand ){
    $selectedHand = $handkeys[ 0 ];
  }

  ## Recup ALL handlers DATAS
  ##---------------------------------------
  my @allHandlers;
  my @auxall = keys( %{ $chapter->{ $domActif }->{ 'handler' } } );  
  for( @auxall ){
    my $homer = $chapter->{ $domActif }->{ 'handler' }->{ $_ }->{ 'MultiHomer' };  
    if( $homer eq 'CombinedType' ){
      push( @allHandlers, $_ );
    }
  }


  ## SELECTED HANDLER ONLY
  ##------------------------
  my $allHandlersChapters = $chapter->{ $domActif }->{ 'handler' };
  $chapter = $chapter->{ $domActif }->{ 'handler' }->{ $selectedHand }; 

  my %chapterX = ( 'xxxx', $chapter ); 
  &TransformVars( $composs, \%chapterX );

  ##---------------------------------------------------------------------------------------------------------
  ##---------------------------------------------------------------------------------------------------------
  ##    ASSISTANT ??????
  my $valab;
  my $helpText   = 0;
  my $IDX_ASSIST = 0;
  

  if( defined(CGI::param( 'AssistCreator' ) ) ){
    $helpText = $text{ 'assist_handler_0' };
    $filethtml = $conf->{templateAssist};
    # clean composants PHASE 0
    #--------------------------
    my @keep = ('idHandler');
    CleanComposants( $composs, \@keep );
  }
  

  if( defined(CGI::param( 'AssistCreate_Next' ) ) ){ # NEXT PHASE d'assistance
    $IDX_ASSIST = CGI::param( 'IDX_WIZARD' );

    if( $IDX_ASSIST == 0 ){ 
      my $idhandler = CGI::param( 'idHandler' );
      $filethtml = $conf->{templateAssist};
      if( !length( $idhandler ) ){ ## nom de handler non saisie
        $helpText = $text{ 'assist_handler_0' };
        # clean composants PHASE 0
        #--------------------------
        my @keep = ('idHandler');
        CleanComposants( $composs, \@keep );
        $message = $text{'lab_error_7'};
      }
      else { ## name OK --> PHASE suivante
        $helpText = $text{ 'assist_handler_1' };
        my @keep = ('idHandler', 'Enabledproxy', 'Recursive');
        CleanComposants( $composs, \@keep );
        $valab = &getRefValueInCompo( $composs, 'idHandler' );
        $valab->{ 'defValue' } = $idhandler;
        $valab = &getRefValueInCompo( $composs, 'Enabledproxy' );
        $valab->{ isChecked } = "";
        $valab = getRefValueInCompo( $composs, 'Recursive' );
        $valab->{ isChecked } = "";

        $IDX_ASSIST = 1;
      }
    } elsif( $IDX_ASSIST == 1 ){
      my $idhandler     = CGI::param( 'idHandler' );
      my $checkEnabled  = defined( CGI::param( 'Enabledproxy' ) ) ? 'CHECKED' : '';
      my $checkRecurs   = defined( CGI::param( 'Recursive' ) ) ? 'CHECKED' : '';
      $filethtml = $conf->{templateAssist};
      if( !length( $idhandler ) ){ ## nom de handler non saisie
        $helpText = $text{ 'assist_handler_1' };
        # clean composants PHASE 0
        #--------------------------
        my @keep = ('idHandler', 'Enabledproxy', 'Recursive');
        CleanComposants( $composs, \@keep );
        $message = $text{'lab_error_7'};
      }
      else { ## name OK --> PHASE suivante
        $helpText = $text{ 'assist_handler_2' };
        my @keep = ('idHandler', 'Enabledproxy', 'Recursive', 'AttrLdap', 'idCodeAppli');
        CleanComposants( $composs, \@keep );
        $valab = &getRefValueInCompo( $composs, 'idHandler' );
        $valab->{ 'defValue' } = $idhandler;
        $valab = &getRefValueInCompo( $composs, 'Enabledproxy' );
        $valab->{ 'isChecked' } = $checkEnabled;
        $valab = getRefValueInCompo( $composs, 'Recursive' );
        $valab->{ 'isChecked' } = $checkRecurs;
        $valab = getRefValueInCompo( $composs, 'AttrLdap' );
        $valab->{ 'defValue' } = '';
        $valab = getRefValueInCompo( $composs, 'idCodeAppli' );
        $valab->{ 'defValue' } = '';
        $IDX_ASSIST = 2;
      }    
    } elsif( $IDX_ASSIST == 2 ){
      my $idhandler     = CGI::param( 'idHandler' );
      my $checkEnabled  = defined( CGI::param( 'Enabledproxy' ) ) ? 'CHECKED' : '';
      my $checkRecurs   = defined( CGI::param( 'Recursive' ) ) ? 'CHECKED' : '';
      my $attrldap      = CGI::param( 'AttrLdap' );
      my $codeappli     = CGI::param( 'idCodeAppli' );
      $filethtml = $conf->{templateAssist};
      if( !length( $idhandler ) ){ ## nom de handler non saisie 
        $helpText = $text{ 'assist_handler_1' };
        # clean composants PHASE 0
        #--------------------------
        my @keep = ('idHandler', 'Enabledproxy', 'Recursive');
        CleanComposants( $composs, \@keep );
        $message = $text{'lab_error_7'};

        ##### ATTRLDAP ET CODE APPLI A TESTER ?????? 
        
      }
      else { ##  --> PHASE suivante
        $helpText = $text{ 'assist_handler_3' };
        my @keep = ('idHandler', 'Enabledproxy', 'Recursive', 'AttrLdap', 'idCodeAppli', 'BasePub', 'BasePriv');
        CleanComposants( $composs, \@keep );
        $valab = &getRefValueInCompo( $composs, 'idHandler' );
        $valab->{ 'defValue' } = $idhandler;
        $valab = &getRefValueInCompo( $composs, 'Enabledproxy' );
        $valab->{ 'isChecked' } = $checkEnabled;
        $valab = getRefValueInCompo( $composs, 'Recursive' );
        $valab->{ 'isChecked' } = $checkRecurs;
        $valab = getRefValueInCompo( $composs, 'AttrLdap' );
        $valab->{ 'defValue' } = $attrldap;
        $valab = getRefValueInCompo( $composs, 'idCodeAppli' );
        $valab->{ 'defValue' } = $codeappli;
        $valab = getRefValueInCompo( $composs, 'BasePub' );
        $valab->{ 'defValue' } = '';
        $valab = getRefValueInCompo( $composs, 'BasePriv' );
        $valab->{ 'defValue' } = '';
        $IDX_ASSIST = 3;
      }
    } elsif( $IDX_ASSIST == 3 ){ ## VALID !!!!
      my $idhandler     = CGI::param( 'idHandler' );

      $xmlemon->{ 'domain' }->{ $domActif }->{ 'handler' }->{ $idhandler }->{ 'MultiHomer' } = CGI::param('selTypeHandler');
      my $locchap = $xmlemon->{ 'domain' }->{ $domActif }->{ 'handler' }->{ $idhandler };

      $locchap->{ 'VirtualHost' }   = CGI::param('selVirtualHost');
      $locchap->{ 'Organization' }  = CGI::param('AttrLdap');
      $locchap->{ 'BasePriv' }      = CGI::param('BasePriv');
      $locchap->{ 'BasePub' }       = CGI::param('BasePub');
      $locchap->{ 'AppliCode' }     = CGI::param('idCodeAppli');
      $locchap->{ 'EnableLWPProxy' }= defined( CGI::param('Enabledproxy') ) ? '1' : '0';
      $locchap->{ 'ChaseRedirect'}  = defined( CGI::param('Recursive'  ) ) ? '1' : '0';

      &writeXML( $xmlemon, $config{'XML_file'});

      ## MISE A JOUR DES AFFICHAGES AVEC LE NOUVEAU HANDLER !!!!!
      ##------------------------------------------------------------
      $chapter  = getChapterXML( $xmlemon, "domain" );
      $handlers = $chapter->{ $domActif }->{ "handler" };
      @handkeys = keys( %{$handlers} );
      @handkeys = sort( @handkeys );

      @comboHandlers = undef;
      
      for( @handkeys ){
        my $item = { "labOption" => $_, "idValue" => $_ };
        push( @comboHandlers, $item );
      }

      my $item = { "labOption" => $text{ lab_55 }, "idValue" => $text{ lab_55 } };
      push( @comboHandlers, $item );

      @auxall = keys( %{ $chapter->{ $domActif }->{ 'handler' } } );
      for( @auxall ){
        $homer = $chapter->{ $domActif }->{ 'handler' }->{ $_ }->{ 'MultiHomer' };
        if( $homer eq 'CombinedType' ){
           push( @allHandlers, $_ );
        }
      }
      ## SELECTED HANDLER ONLY
      ##------------------------
      $allHandlersChapters = $chapter->{ $domActif }->{ 'handler' };
      $selectedHand = $idhandler;
      $chapter = $chapter->{ $domActif }->{ 'handler' }->{ $selectedHand }; 
      
      %chapterX = ( 'xxxx', $chapter );
      $conf     = &getXmlPage( "handlers_0" );
      if( $mode eq 'Expert' ){  
        $composs   = &getAllComposants( $conf->{'composants'}->{ 'expert' } );
      } else {
        $composs   = &getAllComposants( $conf->{'composants'}->{ 'normal' } );
      }
 
      $composs = &polyGlotTab( $composs, \%text );
      &TransformVars( $composs, \%chapterX );
 
    }
  }
  #     END OF WIZARD THING
  #//////////////////////////////////////////////////////////////////////////
  #//////////////////////////////////////////////////////////////////////////

  
  ##//////////////////////////////////////////////////////////////////////////
  ##//////////////////////////////////////////////////////////////////////////
  #######  VARIABLES PASSES EN PARAMETRE AU TEMPLATE

  $valab     = getRefValueInCompo( $composs, 'Enabledproxy' );
  $valab->{ isChecked } = $chapter->{ 'EnableLWPProxy' } ? "CHECKED" : "";
  $valab        = getRefValueInCompo( $composs, 'Disabled' );
  $valab->{ isChecked } = $chapter->{ 'DisableAccessControl' } ? "CHECKED" : "";
  $valab        = getRefValueInCompo( $composs, 'StopCookie' );
  $valab->{ isChecked } = $chapter->{ 'StopCookie' } ? "CHECKED" : "";
  $valab        = getRefValueInCompo( $composs, 'Recursive' );
  $valab->{ isChecked } = $chapter->{ 'ChaseRedirect' } ? "CHECKED" : "";
  $valab        = getRefValueInCompo( $composs, 'SoftControl' );
  $valab->{ isChecked } = $chapter->{ 'SoftControl' } ? "CHECKED" : "";

    
  ##--------------------------------------------------------
  ##--------------------------------------------------------
  ## MULTI-HOMING HANDLER ?????  !!!!!!!!!! VITUALHOST TYPE
  ##--------------------------------------------------------
  my $exHomer   =  $chapter->{ 'MultiHomer' };
  my $typeHomer =  $exHomer;
    
  ## TYPE HANDLER CHANGE ?????
  ##----------------------------------------------  

  if( defined(CGI::param('selTypeHandler')) ){
    if( $flagSameHandler ){
      $typeHomer = CGI::param('selTypeHandler');
    } 
    if( $flagSameHandler && ($typeHomer ne $exHomer) ){
      my $flag = 1;
      if( $exHomer eq 'CombinedType' ){
        if( !&OkToChange( $allHandlersChapters, $selectedHand, $message )){  
          $flag = 0;
          $typeHomer = $exHomer;
        }  
      }    
      if( $flag ){    
        $chapter->{ 'MultiHomer' } = $typeHomer;
        if( $typeHomer ne 'MultiHomingType' ){
          delete( $chapter->{ 'MultiHoming' } );
        }
        ## maj du XML
        ##------------
#        &writeXML( $xmlemon, $config{'XML_file'});
      }    
    }
  }

  my $flagHomer   = $typeHomer eq 'MultiHomingType' ? 1 : 0;
  my $virtualHost = $chapter->{ 'VirtualHost' };
  if( !$virtualHost ) {
    $virtualHost = 'byName';
  }
  my $newVH       = $virtualHost;

  ## VIRTUAL HOST CHANGE ????
  ##--------------------------
  if ( defined (CGI::param ('selVirtualHost')) ) { 
    if( $flagSameHandler ){
      $newVH = CGI::param ('selVirtualHost');
    }
    if( $flagSameHandler && ($newVH ne $virtualHost ) ){
      $virtualHost = $newVH;
      
      #$chapter->{ 'VirtualHost' } = $virtualHost;
      ## maj du XML
      ##------------
      #&writeXML( $xmlemon, $config{'XML_file'});
    } 
  }  

  ## PROXY ENABLED CHANGE ??
  ##------------------------
  if( $flagSameHandler ){
    $valab     = getRefValueInCompo( $composs, 'Enabledproxy' );
    if(  defined (CGI::param ('Enabledproxy')) ) {
      $valab->{ isChecked } = 'CHECKED';
    } else {
      $valab->{ isChecked } = '';
    } 
  }
  ##
  ## si c est un handler MULTI-HOMING --> chargement des liste de handlers "homed"
  ## et dispo (non homed) pour le MULTI-HOMING 
  ##----------------------------------------------
  my @tabHomed;
  my @tabDispo;
 
  if( $typeHomer eq 'MultiHomingType' ){
   
    my $line = $chapter->{ 'MultiHoming' };
    @tabHomed = split( /,/, $line );
   
    for( my $i=0; $i< @allHandlers; $i++ ){
      my $h1 = $allHandlers[ $i ];
      if( $h1 ne $selectedHand ){
        my $flag = 0;
        for( @tabHomed ){
          if( $h1 eq $_ ){
            $flag = 1;
          }
        }
        if( !$flag ){
          push( @tabDispo, $h1 );          
        }
      } 
    }
  }

  ##//////////////////////////////////////////////////////////////////////////
  ##//////////////////////////////////////////////////////////////////////////
  ##   Traitement des ADD / REMOVE HANDLERS dans les multi homing

  if( defined (CGI::param ('RemoveHomed')) ) {  
    my $hand = CGI::param ('listHomed');
    my @nList;
    push(@tabDispo, $hand);
    for( @tabHomed ){
      if( $_ ne $hand){
        push(@nList, $_);
      } 
    } 
    @tabHomed = @nList;
    my $string = join(',', @tabHomed);  
    
    ## maj du XML
    ##-------------
    $chapter->{ 'MultiHoming' } = $string;
    &writeXML( $xmlemon, $config{'XML_file'});
  }
  if( defined (CGI::param ('AddDispo')) ) {  
    my $hand = CGI::param ('listDispo');
    push( @tabHomed, $hand );
    my @nlist;
    for( @tabDispo ){
      if( $_ ne $hand ){
        push( @nlist, $_ );
      }
    }  	
    @tabDispo = @nlist;  
    my $string = join( ',', @tabHomed );
    
    ## maj du XML
    ##-------------
    $chapter->{ 'MultiHoming' } = $string;
    &writeXML( $xmlemon, $config{'XML_file'});
  }

  if( !$selectedHand ){
    $selectedHand = $text{ lab_55 };
  }  
  my $flagAddHandler = ($selectedHand eq $text{ lab_55 });

  my @logLevels = ( 'debug', 'info', 'notice', 'warn', 'error', 'crit', 'alert', 'emerg', $text{'lab_68'} );

  $vars= { style           => $styl,
           title           => $title,  
           mode            => $mode,
	   cgi             => 'handlers_0.cgi',
           css             => $_style,
     	   parent          => $0,
           label           => '0',
	   langa           => \%text,
           tab_session     => $tabular,
           composall       => $composs,
           combo_handlers  => \@comboHandlers,
	   labCombo        => $title,
           option_selected => $selectedHand,
           domaine         => $domActif,
	   flag_homer      => $flagHomer,
           type_homer      => $typeHomer,
           exHandler       => $selectedHand,
           homed_handlers  => \@tabHomed,
           dispo_handlers  => \@tabDispo,
	   lab_6	   => $text{ 'lab_6' },
	   lab_7	   => $text{ 'lab_7' },
	   lab_42	   => $text{ 'lab_42' },
	   lab_43	   => $text{ 'lab_43' },
           virtual_host    => $virtualHost,
           message         => $message,
           flagAddHandler  => $flagAddHandler,
           lab_58          => $text{ 'lab_58' },
           helpText        => $helpText,
           lab_prev        => $text{ 'lab_prev' },
           lab_next        => $text{ 'lab_next' },
           IDX_ASSIST      => $IDX_ASSIST,
           lab_27          => $text{ 'lab_27' },
           logLevels       => \@logLevels
       }; 

  $vars->{style} = &getStyle($styl, $vars->{checked});

  print "Content-type: text/html\n";
  $tt->process($filethtml,$vars) || die $tt->error();

=pod      
  $dump1 = Dumper( $composs );
  print("<BR><HR>Dump(1) ---> $dump1 <HR><BR>");

  print("<BR><HR>Dump(2) ---> $dump2 <HR><BR>");

  my @lo =CGI::param();
  my $l =Dumper(@lo);
  print "$l";
  print( "<BR><hr><BR>" );
  for( @lo ){
    my $loc   = CGI::param( $_ );
    print("$_ --> $loc <br>");
  }
=cut

}  else { ## Traitement du "SUBMIT"
  ##########################################################
  my $dom    = CGI::param('idDomain');
  my $_style = CGI::param('style');
  my $mode   = CGI::param('mode');

  my $selectedHand = CGI::param('idHandler'); ## PAS cbHAndler a cause de ADD HADLER !!!!!

  my $xmlemon   = getXML( $config{'XML_file'} );
  my $chapter   = getChapterXML( $xmlemon, 'domain' );
  $chapter      = $chapter->{ $dom }->{ 'handler' }->{ $selectedHand };

  ##----------------------------------------------------------------------------------------
  #   SI LE HANDLER n existe pas --> CREATION DE L ANCRAGE XML and ROCK'N ROLL
  ##----------------------------------------------------------------------------------------
  $dump1 = "JE SUIS ICI";
  $dump2 = Dumper( $chapter );
  if( !$chapter ){
    $dump1 = "JE SUIS LA et pas ICI";
    $xmlemon->{ 'domain' }->{ $dom }->{ 'handler' }->{ $selectedHand }->{ 'MultiHomer' } = CGI::param('selTypeHandler');
    $chapter = $xmlemon->{ 'domain' }->{ $dom }->{ 'handler' }->{ $selectedHand };
    $dump2 = Dumper( $chapter );
  }
  $chapter->{ 'MultiHomer' }    = CGI::param('selTypeHandler');
  $chapter->{ 'VirtualHost' }   = CGI::param('selVirtualHost');
  if( defined( CGI::param( 'IPAdress' )) ){
    $chapter->{ 'IPAdress' }   = CGI::param('IPAdress');
  } else {
    delete( $chapter->{ 'IPAdress' } ); 
  }
  
  
  $chapter->{ 'Allow' }         = CGI::param('selAllow');
  $chapter->{ 'Organization' }  = CGI::param('AttrLdap');
  $chapter->{ 'BasePriv' }      = CGI::param('BasePriv');
  $chapter->{ 'BasePub' }       = CGI::param('BasePub');    
  $chapter->{ 'AppliCode' }     = CGI::param('idCodeAppli');
  $chapter->{ 'DisableAccessControl' }      = defined( CGI::param('Disabled') ) ? '1' : '0';
  if( defined( CGI::param('Enabledproxy') ) ){
    $chapter->{ 'EnableLWPProxy' }  = '1';
    $chapter->{ 'LWPTimeout' }    = CGI::param('LWPTimeout');
    $chapter->{ 'ChaseRedirect'   }   = defined( CGI::param('Recursive'  ) ) ? '1' : '0';
  } else {
    $chapter->{ 'EnableLWPProxy' }  = '0';
    delete( $chapter->{ 'LWPTimeout' } );
    delete( $chapter->{ 'ChaseRedirect'  } );
  }  
  
  $chapter->{ 'Header' }        = CGI::param('Header');
  $chapter->{ 'ProxyPatterns' } = CGI::param('Ics');
  $chapter->{ 'MotifIn' }       = CGI::param('MotifIn');
  $chapter->{ 'MotifOut' }      = CGI::param('MotifOut');

  if( defined( CGI::param( 'PlugInBackend' )) ) {
    $chapter->{ 'BackendPlugIn' } = CGI::param('PlugInBackend');
  }  
  if( defined( CGI::param( 'PlugInHeader'  )) ) {
    $chapter->{ 'HeaderPlugIn' }  = CGI::param('PlugInHeader' );
  }  
  if( defined( CGI::param( 'PlugInHtml'    )) ) {
    $chapter->{ 'RewritePlugIn' }    = CGI::param('PlugInHtml'   );
  }  
  if( defined( CGI::param( 'PlugInPolicy'  )) ) {
    $chapter->{ 'PolicyPlugIn' }  = CGI::param('PlugInPolicy' );
  }  

  $chapter->{ 'Portal'      }   = CGI::param('Portal'     );
  $chapter->{ 'ProxyExt'    }   = CGI::param('ProxyExt'   );
  $chapter->{ 'SoftControl' }   = defined( CGI::param('SoftControl') ) ? '1' : '0';
  $chapter->{ 'StopCookie'  }   = defined( CGI::param('StopCookie' ) ) ? '1' : '0';
  $chapter->{ 'LogLevel'    }   = CGI::param('LogLevel'   );

  &writeXML( $xmlemon, $config{'XML_file'});    

=pod  
  print( "Content-type: text/html\n" );
  print( "\n" );

  print("<HR><BR> $dump1 <BR>$dump2<HR>");
  
  my @lo =CGI::param();
  for( @lo ){
    my $loc   = CGI::param( $_ );
    print("$_ --> $loc <BR>");
  }
  
#  print( Dumper( $chapter ) );
=cut
  &redirect( "handlers_0.cgi?mode=$mode&style=$_style&Domain=$dom" );
}
#
############ C FINI
