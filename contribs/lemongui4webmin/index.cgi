#!/usr/bin/perl  -w
#use strict;
use Template;
use  CGI;
use Data::Dumper;
require './lemonldap-lib.pl';


#my $dump1;

if( !$config{'XML_file'} ){
  &redirect( "$gconfig{'webprefix'}/config.cgi?$module_name" );
=pod  
  print( "Content-type: text/html\n" );
  print( "\n" );
  print( "No  XML config file $config{XML_file} <br>  go to " );
  print( "<a href= $gconfig{'webprefix'}/config.cgi?$module_name> configuration</a>");
=cut  
  exit;
}

#$dump1 = Dumper( %config );
#######################################################################
#
my $mode;
my $flipflop;
my $check = 0;
my $styl ;
my $vars;
my $tab_active;
my $tt = Template->new( {# ABSOLUTE => 1,
    	  		   PREC_CHOMP =>1,
    		  	   POST_CHOMP =>1, } );

my $conf      = &getXmlPage( "about" );
my $filethtml = $conf->{'template'};
my $confgenTT = $conf->{'templateConfGen'};
my $title     = $text{ &dePourCent( $conf->{title} ) };
  
#######################################################################
#
my $_style=  CGI::param('style');
my $tabular = [];
if (CGI::param('mode') =~ /pert/) { # mode expert beaucoups plus d option 
    
    $mode='Expert' ;
    $tabular = &getTab( $conf->{tabs}->{expert} );
    $tabular = &polyGlotTab( $tabular, \%text );
    $tabular = &ajustLink ($tabular,$mode,$_style);

    $flipflop= 'Normal';
} else { 
  $mode ='Normal';
  
  $tabular = &getTab( $conf->{tabs}->{normal} );
  $tabular = &polyGlotTab( $tabular, \%text );
   $tabular = &ajustLink ($tabular,$mode,$_style);
  
  $flipflop= 'Expert';
} # end else

my $flagApplyModifs = &IsXMLModified( $config{'XML_file'} );
my $flagAPACHE      = &IsApacheRunning();

my $para3 = $config{'XML_file'};
 
$tab_active = '3' ;
if (!$config{'Style'} ) { ## je dois rediriger la personne vers le module de config 
  $styl  ="conf_style" ; ## style par defaut 
  $vars= { style   => $styl,
           checked => $check,
    	   title   => $title, 
           mode    => $mode,
           cgi => 'index.cgi',
           css     => $_style,
           label   => $flipflop, 
     	   about   => $text{lemonldap_invite},
           parent  => $0, 
           tab_about => $tabular,
	   langa   => \%text
         };
  ##$dump1 = Dumper( $para3 );
  &redirect( "$gconfig{'webprefix'}/config.cgi?$module_name" );
  #print( "<a href= $gconfig{'webprefix'}/config.cgi?$module_name> configuration</a>");
  exit();
  
} else {
  $styl = $config{'Style'};
  my $c;
  $styl  = &getStyle( $styl, $c );
##  my $para1 = $config{'XML_XSD'};
  my $para2 = $config{'httpd_conf'};

  ##############
  ## controle de l'existance et de la validite du fichier XML passe en parametre
  if( &isValidXML( $para3 ) < 1 ){ ## 0 == fichier inexsistant //  -1 == bad xml format
    &restoreXMLFile( $para3 );  
  }
  my $message = 0;
  
  #############
  #  Application des modifs --> copy work file to prod file
  if( defined( CGI::param('ApplyModifs'))) {
    my $result = &ApplyXMLModifs( $config{'XML_file'} );
    if( !$result ){
      $flagApplyModifs = 0;
    } else {
      $message = $text{'lab_error_10'};
    }
  }

  #############
  #  Annulation des modifs --> copy prod file to work file
  if( defined( CGI::param('DiscardModifs'))) {
    my $result = &DiscardXMLModifs( $config{'XML_file'} );
    if( !$result ){
      $flagApplyModifs = 0;
    } else {
      $message = $text{'lab_error_10'};
    }
  }

  #############
  #  GENERATE CONFIG FILES
  if( defined( CGI::param('GenerConfigFiles'))) {
    $message = &GenerateConfigFilesWT( $config{'XML_file'}, $confgenTT );
  }
  
  #############
  #  STOP APACHE 
  if( defined( CGI::param('StopApache'))) {
    if( !$config{'stop_cmd'} ){
      $message = "Command not defined in module config"
    } else {
      my $com = $config{'stop_cmd'} . ' 2>&1> /dev/null';
      $message = ` $com `;
      sleep( 1 );
      $flagAPACHE      = &IsApacheRunning();
    }
  }

  #############
  #  START APACHE
  if( defined( CGI::param('StartApache'))) {
    if( !$config{'start_cmd'} ){
      $message = "Command not defined in module config"
    } else {
      my $com = $config{'start_cmd'} . ' 2>&1> /dev/null';
      $message = ` $com `;
      sleep( 1 );
      $flagAPACHE      = &IsApacheRunning();
    }
  }

  #############
  #  RESTART APACHE
  if( defined( CGI::param('RestartApache'))) {
    if( !$config{'restart_cmd'} ){
      $message = "Command not defined in module config"
    } else {
      my $com = $config{'restart_cmd'} . ' 2>&1> /dev/null';
      $message = ` $com `;
      sleep( 2 );
      $flagAPACHE      = &IsApacheRunning();
    }
  }
  
  ## FICHIERS XML CONFIG BAKx ????
  ##-------------------------------
  my $tmodxml = &GetNumXmlConfMod( $config{'XML_file'} );
  
  $vars= { style   => $styl,
    	   checked =>$c, 
    	   title   => $title, 
    	   mode    => $mode,
    	   css     => $_style,
    	   label   => $flipflop,
    	   para3   => $para3,
    	   para2   => $para2,
           ## para1   => $para1,
    	   parent  => $0, 
   	   tab_about => $tabular,
	   langa   => \%text,
           lab_63  => $text{'lab_63'},
           lab_65  => $text{'lab_65'},
           flagApplyModifs => $flagApplyModifs,
           flagAPACHE      => $flagAPACHE,     
           message         => $message,
           tabDTXml        => $tmodxml,
           lab_64          => $text{ 'lab_64' }
         };
}
if (CGI::param('style')) {
  $vars->{style} = &getStyle( CGI::param('style'), $vars->{checked} );
}

print "Content-type: text/html\n";
$tt->process($filethtml,$vars) || die $tt->error();

#print( "para3 = $dump1" );


