package Lemonldap::NG::Manager::Base;

use strict;

use MIME::Base64;
use Time::Local;
use CGI;

our $VERSION = '0.2';

our @ISA = qw(CGI);

sub header {
    my $self = shift;
    $self->SUPER::header(@_);
}

sub header_public {
    my $self = shift;
    my $filename = shift;
    $filename ||= $ENV{SCRIPT_FILENAME};
    my @tmp = stat($filename);
    my $date = $tmp[9];
    my $hd = gmtime($date);
    $hd =~s/^(\w+)\s+(\w+)\s+(\d+)\s+([\d:]+)\s+(\d+)$/$1, $3 $2 $5 $4 GMT/;
    my $year = $5;
    my $cm = $2;
    # TODO 
    if(my $ref = $ENV{TODO_HTTP_IF_MODIFIED_SINCE}) {
	my %month = (jan => 0, feb => 1, mar => 2, apr => 3, may => 4, jun => 5, jul => 6, aug => 7, sep => 8, oct => 9, nov => 10, dec => 11);
	if($ref =~ /^\w+,\s+(\d+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)/) {
	    my $m = $month{lc($2)};
	    $year-- if($m > $month{lc($cm)});
	    $ref = timegm($6,$5,$4,$1,$m,$3);
	    if($ref == $date) {
	        print $self->SUPER::header(-status => '304 Not Modified', @_ );
	        exit;
	    }
	}
    }
    return $self->SUPER::header( '-Last-Modified' => $hd, '-Cache-Control' => 'public', @_ );
}

1;

__END__

=head1 NAME

Lemonldap::NG::Manager::Base - Simple module to extend L<CGI> to manage
HTTP "If-Modified-Since / 304 Not Modified" system.

=head1 SYNOPSIS

  use Lemonldap::NG::Manager::Base;
  
  my $cgi = Lemonldap::NG::Manager::Base->new();
  $cgi->header_public($ENV{SCRIPT_FILENAME});
  print "<html><head><title>Static page</title></head>";
  ...

=head1 DESCRIPTION

Lemonldap::NG::Manager::Base just add header_public subroutine to CGI module to
avoid printing HTML elements that can be cached.

=head1 METHODS

=head2 header_public

header_public works like header (see L<CGI>) but the first argument has to be
a filename: the last modify date of this file is used for reference.

=head2 EXPORT

=head1 SEE ALSO

L<Lemonldap::NG::Manager>, L<CGI>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Xavier Guimard E<lt>x.guimard@free.frE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
