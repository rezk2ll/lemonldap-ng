use File::Copy;
use XML::Simple;
use File::Copy;
use File::Basename;

my $PREFIX = (-e '/etc/debian_version') ? '/usr/share/webmin/' : '../';

do ( $PREFIX . 'web-lib.pl' );

#do './httpd-lib.pl';
&init_config();

###################################################################
#

sub getStyle {
  if ($_[0] =~ /map/i) {
    $_[1] = 0;
    return "conf_style";
  }
  if ($_[0] =~ /lectro/i) {
    $_[1] = 1;
    return "simpage";
  }
  if ($_[0] =~ /golf/i) {
    $_[1] = 2;
    return "golf_style";
  }
}

sub Nerror
{
  print "Content-type: text/html\n";
  print "\n";
  print "<h3>","motif : ",@_,"</h3>\n";
  print "<hr>\n";
  exit;
}


########################################################################
#

sub isValidXML {                   # return 1 == OK
  my $namef = $_[0];               #        0 == fichier inexsitant
  				   #       -1 == XML invalide 

  if( !-e $namef ){
    return 0;
  }
  
  my $pxml = XMLin( $namef, "ForceArray" => "1" );

  if( ! %{$pxml} ) {
    return -1;   
  }

  return 1;
}

################################################################################################
# GENERATION DES FICHIERS DE CONF APACHE
#
sub GenerateConfigFiles {
  my $confile = $_[0];
  my $pxml = XMLin( $confile, "ForceArray" => "1" );
  my $path = $config{'httpd_conf'};

  if( !length($path) ){ ## pas de path pour conf.d dans les params du module !!!
    return $text{'lab_error_12'};
  }

  ## completer si necessaire le path avec le / de fin
  my @lpath = split(//, $path );
  if( $lpath[ @lpath - 1 ] ne '/' ){
    $path .= '/';
  }

  ## tester l existance du path vers conf.d
  if( ! -e $path ){
    return $text{'lab_error_13'};
  }

  my %kk   = (  'Portal'                =>  'portal'         ,
                'BasePub'               =>  'basepub'        ,
                'BasePriv'              =>  'basepriv'       ,
                'EnableLWPProxy'        =>  'enablelwpproxy' ,
                'Organization'          =>  'organization'   ,
                'AppliCode'             =>  'applicode'      ,
                'DisableAccessControl'  =>  'disableaccesscontrol',
                'StopCookie'            =>  'stopcookie'     ,
                'ChaseRedirect'         =>  'chaseredirect'  ,
                'ProxyExt'              =>  'proxyext'       ,
                'ProxyPatterns'         =>  'proxypatterns'  ,
                'MultiHoming'           =>  'multihoming'    ,
                'LWPTimeout'            =>  'lwptimeout'     ,
                'SoftControl'           =>  'softcontrol'    ,
                'Header'                =>  'header'         ,
                'Allow'                 =>  'allow'          ,
                'PolicyPlugIn'          =>  'policyplugin'   ,
                'RewritePlugIn'         =>  'rewriteplugin'  ,
                'HeaderPlugIn'          =>  'headerplugin'   ,
                'BackendPlugIn'         =>  'backendplugin'
              );

  my @igk = keys( %kk );            

  ## recup ts les noms de domaines
  my @doms = keys( %{ $pxml->{'domain'} } );
 
  ## BIG  LOOP
  ##-----------
  my $nbgen = 0;

  for( @doms ){
    # domaine
    my $dom = $_;

    # recup ts les handlers d un domaine
    my @hands = keys( %{ $pxml->{'domain'}->{ $dom }->{ 'handler' }  } );
    for( @hands ){
      
      my $hand = $_;

      my $typHand = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'MultiHomer' };

      if( $typHand eq 'CombinedType' ){
        next;
      }
      
      # contruct file name
      my $fname = $path . $hand . '.conf';
      # create file (erase if exists)
      open( F, ">$fname" ) || return( $text{ 'lab_error_14' } . $fname );
      $nbgen++;
      # recup keys and values for the handler
      my %hand = %{ $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }  };

      ## by name or by IPAdress ???
      my $type = $hand{'VirtualHost'};

      if( !$type ){
        print( F "<virtualhost *:80>\n" );
      } else {
        if( $type eq 'byIPAdress' ){
          my $ip = $hand{'IPAdress'};
          print( F "<virtualhost $ip>\n" );
        } else {
          print( F "<virtualhost *:80>\n" );
        }
      }  

      ## ServerName 
      my $basePub = $hand{ 'BasePub' };
      if( $basePub ){
        my ($sn) = $basePub =~   /\/\/(.*)$/ ;
        print( F "  ServerName \t\t$sn\n" );
      }  

      ## constant
      print( F "  perltranshandler \tLemonldap::Handlers::Generic4a2\n\n" );

      ## all PerlSetVar
      ##----------------
      for( @igk ){
        my $ka  = $_;
        
        if( exists($hand{ $ka }) ){
          my $val = $hand{ $ka };
          if( $val ){
            my $pl  = $kk{ $ka };
            my $tab = length( $pl ) > 16 ? "\t" : "\t\t";
            print( F "  PerlSetVar  $pl $tab $val\n" );
          }  
        }
      }
      ## close virtualhost
      print( F "</virtualhost>\n" );
      close( F );
    }  
  }
  return( "$nbgen ''Apache config files'' generated in $path" );
}  

################################################################################################
# GENERATION DES FICHIERS DE CONF APACHE WITH TEMPLATES
#

sub GenerateConfigFilesWT {
  my $confile   = $_[0];
  my $confgenTT = $_[1];
  my $pxml      = XMLin( $confile, "ForceArray" => "1" );
  my $path      = $config{'httpd_conf'};

  if( !length($path) ){ ## pas de path pour conf.d dans les params du module !!!
    return $text{'lab_error_12'};
  }

  ## completer si necessaire le path avec le / de fin
  my @lpath = split(//, $path );
  if( $lpath[ @lpath - 1 ] ne '/' ){
    $path .= '/';
  }

  ## tester l existance du path vers conf.d
  if( ! -e $path ){
    return $text{'lab_error_13'};
  }

  ## recup ts les noms de domaines
  my @doms = keys( %{ $pxml->{'domain'} } );
 
  ## BIG  LOOP
  ##-----------
  my $nbgen = 0;

  my $TT   = Template->new( OUTPUT_PATH => $path );

  for( @doms ){
    # domaine
    my $dom = $_;

    # recup ts les handlers d un domaine
    my @hands = keys( %{ $pxml->{'domain'}->{ $dom }->{ 'handler' }  } );
    for( @hands ){
      
      my $hand = $_;

      my $typHand = $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }->{ 'MultiHomer' };

      if( $typHand eq 'CombinedType' ){
        next;
      }
      
      # contruct file name
      my $fname = $hand . '.conf';
      $nbgen++;
      # recup keys and values for the handler
      my %hhand = %{ $pxml->{'domain'}->{ $dom }->{ 'handler' }->{ $hand }  };

      ## by name or by IPAdress ???
      my $type = $hhand{'VirtualHost'};
      if( !$type ){
        $type = 'byName';
      }
      ## ServerName
      my $basePub = $hhand{ 'BasePub' };

      my $sn = 'servername';
      if( $basePub ){
        ($sn) = $basePub =~   /\/\/(.*)$/ ;
      }

      for( keys( %hhand ) ){
        if( !length( $hhand{ $_ } ) ){
          delete( $hhand{ $_ } );
        }
      }

      delete $hhand{'IPAdress'};
      delete $hhand{'MultiHomer'};
      delete $hhand{'VirtualHost'};

      my $vars= { type          => $type  ,
                  serverName    => $sn    ,
                  handler       => \%hhand
                };
                
      $TT->process( $confgenTT, $vars, $fname );
      
    }
  }

  return( "$nbgen ''Apache config files'' generated in $path" );
}  


########################################################################
# retourne une H table correspondant à une page complete dans le XML

sub getXmlPage {
  my $page = $_[0]; 
  my $pxml = XMLin( "guiconfig.xml", "ForceArray" => "1" );
  return($pxml->{page}->{$page});
}

########################################################################
# RETOURNE TOUT LE XML D UN FICHIER

sub getXML {
  my $confile = $_[0];
  my $base    = basename( $confile );
  my $workfile = './templates/' . $base;

  if( ! -e $workfile ){
    system("cp -p $confile $workfile");
  }

  my $pxml = XMLin( $workfile, "ForceArray" => "1" );
  UpdateOldXml( $pxml, $confile );
  return( $pxml );
}

########################################################################
# RETOURNE 1 si le fichier de travail est plus recent que le fichier
# en production

sub IsXMLModified {
  my $confile = $_[0];
  my $base    = basename( $confile );
  my $workfile = './templates/' . $base;

  my $prodmt = (stat($confile))[ 9 ];
  my $workmt = (stat($workfile))[ 9 ];

  return ( $workmt > $prodmt ? 1 : 0 ); 
}  

########################################################################
# Met à niveau les fichiers XML avec le param MultiHomer ( type de Handler )

sub UpdateOldXml {
  my $xmlemon   = $_[0];
  my $confile   = $_[1];
  my $chapter   = getChapterXML( $xmlemon, "domain" );

  my @kdom = keys( %{$chapter} );
  my $flagREWRITE = 0;

  for( @kdom ){
    my $dom = $_;
    my $hdom = $chapter->{ $dom }->{ 'handler' };
    if( $hdom ){
      my @khand = keys( %{$hdom} );
      for( @khand ){
        my $hand  = $_;
        my $typeh = $chapter->{ $dom }->{ 'handler' }->{ $hand }->{ 'MultiHomer' };
        if( !$typeh ){
          my $multi = $chapter->{ $dom }->{ 'handler' }->{ $hand }->{ 'MultiHoming' };
          if( $multi ){
            $chapter->{ $dom }->{ 'handler' }->{ $hand }->{ 'MultiHomer' } = 'MultiHomingType';
          } else {
            my $combi = $chapter->{ $dom }->{ 'handler' }->{ $hand }->{ 'MotifOut' };
            if( $combi ){
              $chapter->{ $dom }->{ 'handler' }->{ $hand }->{ 'MultiHomer' } = 'CombinedType';
            } else {
              $chapter->{ $dom }->{ 'handler' }->{ $hand }->{ 'MultiHomer' } = 'GenericType';
            }
          }
          $flagREWRITE = 1;
        } 
      }
    }
  }
  if( $flagREWRITE  ){
    &writeXML( $xmlemon, $confile );
  }  
}

########################################################################
# donne le numero de sequence "bak#" pour sauvegardes auto lors des modifs

sub getNumBakSequence {
  my $confile = $_[0];
  my $numbk   = $_[1];

  my $surch   = $confile . '.bak?';
  
  my @list = glob( $surch );

  my $numseq = @list;
  if( $numseq < $numbk ){
    return $numseq;
  }

  my %h;
  my @tabdt;
  
  for( @list ){
    my $dt = (stat($_))[9];
    $h{ $dt } = $_;
    push( @tabdt, $dt );
  }

  @tabdt = sort( @tabdt );

  my $last = substr($h{ $tabdt[0] }, -1, 1 );
  return $last;
}


########################################################################
# copie le fichier WORK sur le fichier de PROD

sub ApplyXMLModifs {
  my $confile  = $_[0];
  my $base     = basename( $confile );
  my $workfile = './templates/' . $base;

  my $numseq = getNumBakSequence( $confile, 3 );
  my $backf  = $confile . '.bak' . $numseq;
  copy( $confile, $backf );
  
  my $status   = system("cp -p $workfile $confile");
  return $status;
}

########################################################################
# copie le fichier de PROD sur le fichier WORK

sub DiscardXMLModifs {
  my $confile  = $_[0];
  my $base     = basename( $confile );
  my $workfile = './templates/' . $base;

  my $status   = system("cp -p $confile  $workfile");
  return $status;
}
########################################################################
# retourne un tableau de dates de modif des fichiers BAKx du conf

sub GetNumXmlConfMod {
  my $confile = $_[0];
  
  my $surch   = $confile . '.bak?';
  my @list = glob( $surch );

  my $tabdt;
  for( @list ){
    my $dt = (stat($_))[9];
    my $str = localtime($dt);
    push( @{$tabdt}, $str );
  }
  @{$tabdt} = sort( @{$tabdt} );
  return  $tabdt;
}

########################################################################
# ECRIT UN PXML DANS UN FICHIER XML après en avoir fait une copie "bak"

sub writeXML {
  my $pxml    = $_[0];
  my $namef   = $_[1];

  my $base    = basename( $namef );
  $namef      = './templates/' . $base;

  my $backf   = $namef.'.bak';
  my $rootN   = $_[2] || "lemonldapconfig";

  # copie du fichier
  if( !copy( $namef, $backf )){
    ## ???? 
  }
  
  open( $fout, ">$namef" ) || Nerror( $! );

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

########################################################################
# RETOURNE UN CHAPITRE DANS LE XML PASSE EN PARAM

sub getChapterXML {
  my $pxml = $_[0]; 
  my $nam  = $_[1]; 
  my $mod  = $_[2];
  if( !$mod ){  
    return( $pxml->{$nam} );
  } else {
    return( $pxml->{$nam}->{ $mod } );
  }
}

########################################################################
# retourne une H table correspondant à un composant tabulations

sub getTab {
  my $tab = $_[0]; 

  my @k   = keys( %{$tab->{tab}} );
  @k = sort( @k );

  my @tablo;
  for(my $i=0; $i< @k; $i++){
    $tablo[ $i ] = $tab->{tab}->{ $k[$i] };
  }

  return(\@tablo);
}

########################################################################
# comme son nom l indique

sub keyToVal {
  my $h  = $_[0];

  my @k = keys( %{$h} );
  @k = sort( @k );
  my @tab;
  my $firstL = $k[ 0 ];
  
  for( @k ){
    my %hs;
    $hs{ "idValue" } = $_;
    $hs{ "labOption" } = $_; 
    push( @tab, \%hs ); 
  }
  $_[1] = \@tab;
  return $firstL;
}

#---------------------------------------------------------------------
#  CONTROLE DE L'APARTENANCE D'UN HANDLER COMBINED A UN MULTI-HOMING 
#   POUR AUTORISATION DE CHANGEMENT DE TYPE OU SUPPRESSION
#---------------------------------------------------------------------

sub OkToChange {  
  my $allHandlersChapters = $_[0];
  my $selectedHand        = $_[1];

  my @auxall = keys( %{ $allHandlersChapters } );  
  for( @auxall ){
    my $loc  = $_; 
    my $str  = $allHandlersChapters->{ $loc }->{ 'MultiHoming' };  
    my @tabH = split( /,/, $str );
    for( @tabH ){
      if( $selectedHand eq $_ ){
        $_[2] = 'ERROR: ' . $selectedHand . ' ' . $text{lab_error_2} . ' ' . $loc;
        return 0;
      }  
    }
  }    
    
  $_[2] = 0;
  return 1;
}

########################################################################
# retourne tous les composants graph. d'une page (après les tabs)

sub getAllComposants {
  my $comps = $_[0]; 

  my @k     = keys( %{$comps->{comp}} );
  @k = sort( @k );

  my @tablo;
  for(my $i=0; $i< @k; $i++){
    $tablo[ $i ] = $comps->{comp}->{ $k[$i] };
  }
  return(\@tablo);
}

########################################################################
# retourne une ref sur une valeur d un composant

sub getRefValueInCompo {
  my $composs  = $_[0];
  my $idcompo  = $_[1];  #"LastModified"

  for( @{$composs} ){
    my $h = $_;
    if( $h->{ id_input } eq $idcompo ){
      return(  $h  );
    }
  }

  return( undef ); 
}

########################################################################
# supprime le caractère % en début et fin de chaine

sub dePourCent {
  my $line = $_[0];
  $line    =~ s/%(.+)%/$1/;
  return( $line );
}

########################################################################
# teste la présence du caractère % en début et fin de chaine

sub isPourCented {
  my $line = $_[0];

  my $newline = $line =~ /^%.+%$/;
  return $newline;
}

########################################################################
# remplace une variable %xxxx% par le texte EN /FR 

sub polyGlotTab {
  my @tabular = @{$_[0]};
  my %text    = %{$_[1]};

  for(@tabular) { # 0,1 ,2 
    my $hash = $_;
    for(keys %{$hash} ) {
      if( isPourCented( $hash->{$_} ) ){
	$hash->{$_} = $text{ dePourCent( $hash->{$_} ) };
      } 
    }
  }
  return( \@tabular );
}

###################################################################
# remplace les attributs link dans une URL

sub ajustLink {
  my @tabular = @{$_[0]};
  my $mode  = $_[1];
  my $style = $_[2];
  
  my $dom   = $_[3];

  for(@tabular) { # 0,1 ,2 
    my $hash = $_;
    $hash->{link} =~ s/\$mode/$mode/;
    $hash->{link} =~ s/\$_style/$style/;
    if( $dom ){
      $hash->{link} =~ s/\$dom/$dom/;
    }
  }
  return( \@tabular );
}

########################################################################
# crochets certifies // substitue les valeurs def et hid par defaut

sub TransformVars {
  my @composs = @{$_[0]};
  my $chapter = $_[1];
  my @tabk    = keys(%{$chapter});
  my $clebase = $tabk[0]; 

  for( @composs ){
    my $comp = $_;
    
    for( keys(%{$comp} )) {
      my $k = $_;
      if( $comp->{ $k } =~ /^\$def(.+)/  || 
 	  $comp->{ $k } =~ /^\$hid(.+)/     ){
        my $cle = $1;
        if( $cle eq "id" ) {
          $comp->{ $k } = $clebase;
        } else {
          if( $chapter->{ $clebase }->{ $cle } ){
            $comp->{ $k } = $chapter->{ $clebase }->{ $cle };
          } else {
            $comp->{ $k } = "";
          }
        }
      }
    }
  }
}

###################################################################
#
sub IsApacheRunning {
  if( !($config{'pid_file'}) ) {
    return 0;
  }
  if( -e $config{'pid_file'} ){
    return 1;
  }
  return 0;
}


###################################################################
# RAZ du fichier de conf XML en recopiant le fichier template_conf.xml

sub restoreXMLFile() { 
  copy( "./templates/template_conf.xml", $_[0] ); 
}

###################################################################
#

1;

#  C FINI !!! ooops PERL FINI !!!!
###################################################################

