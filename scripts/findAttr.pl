#!/usr/bin/perl
use strict;

my $IGNORE = join(
    '|', qw(
      csr urldc cfgNum p (?:s|rS)essionInfo dn user mustRedirect password dbi\w+
      reVHosts stack timezone vident _\w+ lmConf table (?:st|db)h res id
      refLocalStorage User Password args conf generate mdone obj error
      authChoiceModules deleted entry macros modules notifObject menuModules
      mailSessionKey mail logoutServices ns service modified force menuError
      cookie SOAPMessage clean func local noQuotes categories noCache

      )
);

my ( $attr, $attrFile );

foreach my $module (qw(common handler manager portal)) {
    open CMD,
      "find lemonldap-ng-$module/lib/Lemonldap/NG -type f -name '*.pm'|";
    my @files;
    while (<CMD>) {
        chomp;
        push @files, $_;
    }
    close CMD;

 #    my @files = qw(lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthChoice.pm);
    foreach my $file (@files) {

        # Ignode old liberty-Alliance
        next if ( $file =~ m#Portal/AuthLA.pm$# );
        next if ( $file =~ /_Struct/ );
        open F, $file;
        $file =~ s#.*/NG/##;
        my $autoload = 0;
        my $pod = 0;
        while (<F>) {
            $autoload = 1 if (/use\s+AutoLoader/);
            if(/^=/) {
                if(/^=cut/){$pod=0;}else{$pod=1};
            }
            next if($pod);
            last if ( /^__END__$/ and not $autoload );
            if (/\$(?:self|args)->\{\s*(\w+)\s*\}/) {
                my $k = $1;
                unless ( $k =~ /^$IGNORE$/o ) {
                    $attr->{$module}->{$1}++;
                    $attrFile->{$module}->{$1}->{$file}++;
                }
            }
        }
        close F;
    }

    #use Data::Dumper;
    #print Dumper($attr);
}

open F, 'doc/pages/documentation/latest/parameterlist.html';
my $documentedAttr;
while (<F>) {
    next unless (/<td class="col1.*?">\s*(\w+)\s*<\/td>/);
    $documentedAttr->{$1}++;
}
close F;

open F, 'lemonldap-ng-manager/lib/Lemonldap/NG/Manager/_Struct.pm';
my $managedAttr;
my $buf;
while (<F>) {
    $buf = '' if ( $buf =~ /,$/ );
    $buf .= $_;
    $managedAttr->{$1}++ if ( $buf =~ /=>\s*'\w+:\/(\w+)/s );
}


close F;
my ( $unmanagedAttr, $undocumentedAttr );
foreach my $module (qw(common handler manager portal)) {
    foreach my $k ( keys %{ $attr->{$module} } ) {

        # Parameter that must not be documented
        #next if ( $k =~ /^$IGNORE$/ );
        unless ( defined( $managedAttr->{$k} ) ) {
            $unmanagedAttr->{$module}->{$k}++;
        }
        unless ( defined( $documentedAttr->{$k} ) ) {
            $undocumentedAttr->{$module}->{$k}++;
        }

        # TODO: scan doc/4.1-Configuration-parameter-list.html
    }
    print "\n##### ".uc($module)." #####\n\n### Unmanaged ###\n";
    foreach my $k ( sort keys %{ $unmanagedAttr->{$module} } ) {
        print "$k => "
          . join( ', ', keys( %{ $attrFile->{$module}->{$k} } ) ) . "\n";
    }
    print "\n### Undocumented ###\n";
    foreach my $k ( sort keys %{ $undocumentedAttr->{$module} } ) {
        print "$k => "
          . join( ', ', keys( %{ $attrFile->{$module}->{$k} } ) ) . "\n";
    }
}

