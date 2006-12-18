#!/usr/bin/perl  -w
#use strict;
use Template;
use  CGI;
use Data::Dumper;
require './lemonldap-lib.pl';

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
my $filethtml = $conf->{template};
my $title     = $text{ &dePourCent( $conf->{title} ) };
  
#######################################################################
#
my $_style=  CGI::param('style');
my $tabular = [];
if (CGI::param('mode') =~ /pert/) { # mode expert beaucoups plus d option 
    
    $mode='Expert' ;
    $tabular = &getTab( $conf->{tabs}->{expert} );
    $tabular = &polyGlotTab( $tabular, \%text );

    $flipflop= 'Normal';
    
#$tabular=[{ 
#                link =>'memcached.cgi',
#                etatab=>'plain',
#                labTab=>$text{"session_server"},
#              },
#              { 
#                link =>'domain.cgi',
#                etatab=>'plain',
#                labTab=>$text{"domains"},
#              },
#              { 
#                link =>'ttlconfig.cgi',
#                etatab=>'plain',
#                labTab=>$text{"timelive"},
#              },
#              { 
#                link =>'cluster.cgi',
#                etatab=>'plain',
#                labTab=>'Cluster',
#              },
#              {  
#                link =>"/lemongui4webmin/index.cgi?mode=$mode&style=$_style",
#                etatab=>'selected',
#                labTab=>$text{"about"},
#              }];

} else { 
  $mode ='Normal';
  
  $tabular = &getTab( $conf->{tabs}->{normal} );
  $tabular = &polyGlotTab( $tabular, \%text );
  
  $flipflop= 'Expert';
#  $tabular=  [{ 
#                link =>'memcached.cgi',
#                etatab=>'plain',
#                labTab=>$text{"session_server"},
#              },
#              { 
#                link =>'domain.cgi',
#                etatab=>'plain',
#                labTab=>$text{"domains"},
#              },
#              { 
#                link =>"/lemongui4webmin/index.cgi?mode=$mode&style=$_style",
#                etatab=>'selected',
#                labTab=>$text{"about"},
#              }];

} # end else

$tab_active = '3' ;
if (!$config{'Style'} ) { ## je dois rediriger la personne vers le module de config 
  $styl  ="conf_style" ; ## style par defaut 
  $vars= { style   => $styl,
           checked => $check,
    	   title   => $title, 
           mode    => $mode,
           css     => $_style,
           label   => $flipflop, 
     	   about   => $text{lemonldap_invite},
           parent  => $0, 
           tab_about => $tabular,
	   langa   => \%text
         }; 
} else {
  $styl = $config{'Style'};
  my $c;
  $styl  = &getStyle( $styl, $c );
  my $para1 = $config{'XML_XSD'};
  my $para2 = $config{'httpd_conf'};
  my $para3 = $config{'XML_file'};

  ##############
  ## controle de l'existance et de la validite du fichier XML passe en parametre
  if( &isValidXML( $para3 ) < 1 ){ ## 0 == fichier inexsistant //  -1 == bad xml format
    &restoreXMLFile( $para3 );  
  }

  $vars= { style   => $styl,
    	   checked =>$c, 
    	   title   => $title, 
    	   mode    => $mode,
    	   css     => $_style,
    	   label   => $flipflop,
    	   para3   => $para3,
    	   para2   => $para2,
           para1   => $para1,
    	   parent  => $0, 
   	   tab_about => $tabular,
	   langa   => \%text
         };
}
if (CGI::param('style')) {
  $vars->{style} = &getStyle( CGI::param('style'), $vars->{checked} );
}

print "Content-type: text/html\n";
$tt->process($filethtml,$vars) || die $tt->error();



