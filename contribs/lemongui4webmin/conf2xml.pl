#!/usr/bin/perl 
use Data::Dumper;
use XML::Simple;


sub getXML {
  my $confile = $_[0];

  my $pxml = XMLin( $confile, "ForceArray" => "1" );
  return( $pxml );
}


sub writeXML {
  my $pxml    = $_[0];
  my $namef   = $_[1];

  my $rootN   = $_[2] || "lemonldapconfig";

  open( $fout, ">$namef" ) || die("Oops !! couldn't open $namef !!??");

  XMLout( $pxml, OutputFile => $fout,
                 AttrIndent => 1,
                 RootName => $rootN,
                 KeyAttr => { session =>'id',
                              cache   =>'id', 
                              handler =>'id',
                              application =>'id',                 
                              domain  =>'id',
                              cluster =>'id',
                              node => 'id',  
                               }  );  
  close( $fout );
}

##----------------------------------------------------------------------------------------
##  MAJ DU XML

sub videhash {
  my $h     = $_[ 0 ];
  my $pxml  = $_[ 1 ];
  
  if (exists ($h->{lemonldapdomain})) {
    my $id_handler = $h->{ 'lemonldaphandlerid' };
    my $id_domain  = $h->{ 'lemonldapdomain' };

    ###################################
    ## maj

    print(   "DOMAINE : $id_domain \t --> $id_handler\n" );

    if( length($h->{ 'ipadress' } )) {
      $pxml->{ 'domain' }->{$id_domain}->{ 'handler' }->{ $id_handler }->{ 'VirtualHost' } = 'byIPAdress';
      $pxml->{ 'domain' }->{$id_domain}->{ 'handler' }->{ $id_handler }->{ 'IPAdress' }    = $h->{ 'ipadress' };
    }
    else {
      $pxml->{ 'domain' }->{$id_domain}->{ 'handler' }->{ $id_handler }->{ 'VirtualHost' } = 'byName';
    }

    my %kk   = ( 'lemonldapportal'        =>  ['Portal'      , ''] ,
                 'lemonldapbasepub'       =>  ['BasePub'     , ''] ,
                 'lemonldapbasepriv'      =>  ['BasePriv'    , ''] ,
                 'lemonldapenabledproxy'  =>  ['EnableLWPProxy', '0'] ,
                 'lemonldapattrldap'      =>  ['Organization', ''] ,
                 'lemonldapcodeappli'     =>  ['AppliCode'   , ''] ,
                 'lemonldapdisabled'      =>  ['DisableAccessControl', '0'] ,
                 'lemonldapstopcookie'    =>  ['StopCookie'  , '0'] ,
                 'lemonldaprecursive'     =>  ['ChaseRedirect', '0'] ,
                 'lemonldapproxyext'      =>  ['ProxyExt'    , ''] ,
                 'lemonldapics'           =>  ['ProxyPatterns', ''] ,
                 'lemonldapmultihoming'   =>  ['MultiHoming' , -1] ,
                 'lemonldaplwptimeout'    =>  ['LWPTimeout'  , ''] ,
                 'lemonldapsoftcontrol'   =>  ['SoftControl' , '0'] ,
                 'lemonldapheader'        =>  ['Header'      , ''] ,
                 'lemonldapallow'         =>  ['Allow'       , ''] ,
                 'lemonldappluginpolicy'  =>  ['PolicyPlugIn', ''] ,
                 'lemonldappluginhtml'    =>  ['RewritePlugIn', ''] ,
                 'lemonldappluginheader'  =>  ['HeaderPlugIn', ''] ,
                 'lemonldappluginbackend' =>  ['BackendPlugIn','']
                );                                            
                                                              
    my @kapa = keys( %kk );                                          

    for( @kapa ){                                               
      my $k   = $_;
      my $igp = $kk{ $k }[0];
      my $def = $kk{ $k }[1];
      
      if( length( $h->{ $k } )){
        $pxml->{ 'domain' }->{$id_domain}->{ 'handler' }->{ $id_handler }->{ $igp } = $h->{ $k };
      } else {
        if( $def == -1 ){
          delete( $pxml->{ 'domain' }->{$id_domain}->{ 'handler' }->{ $id_handler }->{ $igp } );
        } else {
          $pxml->{ 'domain' }->{$id_domain}->{ 'handler' }->{ $id_handler }->{ $igp } = $def;
        }
      }
    }
  }
}

##-------------------------------------------------------------------------------------------
## MISE A JOUR DES NOMS DE VARIABLES

sub MajVarNames {
  my $pxml = $_[0];


  ## CACHE.configIpcKey  --> CACHE.ConfigFile
  ##------------------------------------------
  my @confs =  keys( %{$pxml->{'cache'} } );
  for( @confs ){
    my $conf = $_;
    my $ipc  = $pxml->{'cache'}->{ $conf }->{'configIpcKey'};
    if( $ipc ){
      delete( $pxml->{'cache'}->{ $conf }->{'configIpcKey'} );
      $pxml->{'cache'}->{ $conf }->{'ConfigFile'} = $ipc;
      print(" Cache -> $conf  \t\t configIpcKey -> $conf TO ConfigFile\n");
    }
  }  

  ## Domain.Session  -->  Domain.SessionStore
  ##------------------------------------------
  my @doms = keys( %{ $pxml->{'domain'} } );
  for( @doms ){
    # domaine
    my $dom = $_;

    my $sess = $pxml->{'domain'}->{ $dom }->{ 'Session' };
    if( $sess ){
      delete( $pxml->{'domain'}->{ $dom }->{ 'Session' } );
      $pxml->{'domain'}->{ $dom }->{ 'SessionStore' } = $sess;
      print(" Domaine -> $dom  \t\t Session -> $sess  TO SessionStore\n");
    }

    ## HANDLERS
    ##---------------------------------
    # recup ts les handlers d un domaine
    my @hands = keys( %{ $pxml->{'domain'}->{ $dom }->{ 'handler' }  } );
    for( @hands ){
      my $hand = $_;

      my $enabledProxy = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Enabledproxy' }      ;
      my $attrLdap     = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'AttrLdap' }          ;
      my $codeAppli    = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'CodeAppli' }         ;
      my $disabled     = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Disabled' }          ;
      my $plugHtml     = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInHtml' }        ;
      my $plugBackend  = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInBackend' }     ;
      my $plugHeader   = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInHeader' }      ;
      my $plugPolicy   = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInPolicy' }      ;
      my $ics          = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Ics' }               ;
      my $recursive    = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Recursive' }         ;

      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Enabledproxy' } );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'AttrLdap' }     );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'CodeAppli' }    );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Disabled' }     );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInHtml' }   );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInBackend' });
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInHeader' } );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PlugInPolicy' } );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Ics' }          );
      delete( $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Recursive' }    );

      if($enabledProxy ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'EnableLWPProxy' }          =  $enabledProxy;
        print(" Domaine -> $dom  \t Handler -> $hand\t Enabledproxy TO EnableLWPProxy\n");
      }
      if($attrLdap     ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'Organization' }            =  $attrLdap    ;
        print(" Domaine -> $dom  \t Handler -> $hand\t AttrLdap TO Organization\n");
      }
      if($codeAppli    ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'AppliCode' }               =  $codeAppli   ;
        print(" Domaine -> $dom  \t Handler -> $hand\t CodeAppli TO AppliCode\n");
      }
      if($disabled     ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'DisableAccessControl' }    =  $disabled    ;
        print(" Domaine -> $dom  \t Handler -> $hand\t Disabled TO DisableAccessControl\n");
      }
      if($plugHtml     ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'RewritePlugIn' }           =  $plugHtml    ;
        print(" Domaine -> $dom  \t Handler -> $hand\t PlugInHtml TO RewritePlugIn\n");
      }
      if($plugBackend  ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'BackendPlugIn' }           =  $plugBackend ;
        print(" Domaine -> $dom  \t Handler -> $hand\t PlugInBackend TO BackendPlugIn\n");
      }
      if($plugHeader   ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'HeaderPlugIn' }            =  $plugHeader  ;
        print(" Domaine -> $dom  \t Handler -> $hand\t PlugInHeader TO HeaderPlugIn\n");
      }
      if($plugPolicy   ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'PolicyPlugIn' }            =  $plugPolicy  ;
        print(" Domaine -> $dom  \t Handler -> $hand\t PlugInPolicy TO PolicyPlugIn\n");
      }
      if($ics          ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'ProxyPatterns' }           =  $ics         ;
        print(" Domaine -> $dom  \t Handler -> $hand\t Ics TO ProxyPatterns\n");
      }
      if($recursive    ) {
        $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'ChaseRedirect' }           =  $recursive   ;
        print(" Domaine -> $dom  \t Handler -> $hand\t Recursive TO ChaseRedirect\n");
      }
    }
  }

}  

sub main {
  my $confile = $_[0];
  my $xmlfile = $_[1];
  my %hash;

  my $pxml    = getXML( $xmlfile );

  print(   "\nVAR NAMES UPDATED :\n\n" );

  MajVarNames( $pxml );

  print(   "\nHANDLERS UPDATED :\n\n" );
  
  my $HF;
  open( $HF, $confile ) || die("Couldn' open $confile !!\n");
  
  while ( <$HF> ) {
    chomp $_;
    if (/\<virtual/i) {
      # debut vh 
      if(%hash) {
        videhash(\%hash, $pxml);
        %hash =(); 
      }
      ($hash{ipadress}) = /\s(\d.+).$/;
    }
    if(/<\/virtual/i  &&  %hash ) {
      videhash(\%hash, $pxml) ;
      %hash =(); 
    }
    if( /perlsetvar/i ) {
      my ($filler, $nom, $valeur) = /(perlsetvar)\s+(.+)\s+(.+)$/i  ;
      $nom=~ s/^\s+//g;
      $nom=~ s/\s+$//g;
      $valeur=~ s/^\s+//g;
      $valeur=~ s/\s+$//g;

      $valeur=~ s/^'+//g;
      $valeur=~ s/'+$//g;

      $nom=lc($nom);
      $hash{$nom} = $valeur ;
    }
  }

  ## REWRITE XML FILE
  ##------------------
  writeXML( $pxml, $xmlfile );
}

############################################

if( @ARGV != 2 ){
  print("-------------------------------------------------\n\n");
  print("USAGE: conf2xml config_file_name xml_file_name (names with complete path)\n\n\n");
} else {
  main($ARGV[0], $ARGV[1] );
  print( "\n" );
}  

############################################

