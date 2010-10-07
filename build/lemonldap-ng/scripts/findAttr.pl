#!/usr/bin/perl
foreach my $k ( sort keys %$unmanagedAttr ) {

}

use strict;
my $IGNORE = join(
    '|', qw(
      csr urldc cfgNum p (?:s|rS)essionInfo dn user mustRedirect password dbi\w+
      reVHosts stack timezone vident _\w+ lmConf table (?:st|db)h res id
      refLocalStorage
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
        while (<F>) {
            $autoload = 1 if (/use\s+AutoLoader/);
            last if ( /^__END__$/ and not $autoload );
            if (/\$self->\{\s*(\w+)\s*\}/) {
                my $k = $1;
                unless ( $k =~ /^$IGNORE$/ ) {
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

open F, 'lemonldap-ng-manager/lib/Lemonldap/NG/Manager/_Struct.pm';
my $managedAttr;
my $buf;
while (<F>) {
    $buf = '' if($buf =~ /,$/);
    $buf.=$_;
    $managedAttr->{$1}++ if ($buf =~ /=>\s*'\w+:\/(\w+)/s);
}
my $unmanagedAttr;
foreach my $module (qw(common handler manager portal)) {
    foreach my $k ( keys %{ $attr->{$module} } ) {

        # Parameter that must not be documented
        #next if ( $k =~ /^$IGNORE$/ );
        unless ( defined( $managedAttr->{$k} ) ) {
            $unmanagedAttr->{$module}->{$k}++;
        }

        # TODO: scan doc/4.1-Configuration-parameter-list.html
    }
    foreach my $k ( sort keys %{ $unmanagedAttr->{$module} } ) {
        print "$k => "
          . join( ', ', keys( %{ $attrFile->{$module}->{$k} } ) ) . "\n";
    }
}

