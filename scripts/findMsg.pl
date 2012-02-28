#!/usr/bin/perl

use strict;

my $errorMsg;

foreach my $module (qw(common handler manager portal)) {
    open CMD,
      "find lemonldap-ng-$module/lib/Lemonldap/NG -type f -name '*.pm'|";
    my @files;
    while (<CMD>) {
        chomp;
        push @files, $_;
    }
    close CMD;

    #my @files = qw(lemonldap-ng-portal/lib/Lemonldap/NG/Portal/AuthChoice.pm);
    foreach my $file (@files) {
        open F, $file;
        $file =~ s#.*/NG/##;
        $_ = <F>;
        unless (/^##\s*\@file/) {
            push @{ $errorMsg->{$module}->{undocumented} }, $file;
            next;
        }
        my $autoload = 0;
        while (<F>) {
            next if /^(?:\s*#|\*lmLog|sub lmLog)/;
            $autoload = 1 if (/use\s+AutoLoader/);
            last if ( /^__END__$/ and not $autoload );
            next unless (/abort|lmLog|STDERR/);
            if (/lmLog/) {
                $_ .= <F> while ( !/[\)\}];/s );
            }
            else {
                $_ .= <F> while ( !/(?:\s+if\s*\()?;$/ );
            }
            $_ =~ s/\n//gs;
            my ( $msg, $level );
            if (/lmLog/) {
                /lmLog\s*\(\s*(.+?)\s*,\s*(['"])(info|notice|warn|error)\2/s
                  or next;
                ( $msg, $level ) = ( $1, $3 );
            }
            elsif (/abort/) {
                /abort\s*\(\s*(.+?)\s*(?:,\s*(.+?)\s*)?\)/s or next;
                ( $msg, $level ) = ( "$1 ($2)", 'abort' );
            }
            else {
                $level = 'error';
                /STDERR\s+(.*)(?:\s+if\s*\()?;$/ or next;
                $msg = $1;
            }
            push @{ $errorMsg->{$module}->{$level} }, $msg;
        }
        close F;
    }
    print "\n###### " . uc($module) . " ######\n";
    foreach ( @{ $errorMsg->{$module}->{undocumented} } ) {
        print "## No Doxygen ## $_\n";
    }
    foreach my $level (qw(abort error warn notice info)) {
        my $last = '';
        next unless ( ref( $errorMsg->{$module}->{$level} ) );
        foreach ( sort ( @{ $errorMsg->{$module}->{$level} } ) ) {
            print "[$level] $_\n" unless ( $_ eq $last );
            $last = $_;
        }
    }
}
