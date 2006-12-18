#!/usr/bin/perl
# httpd-lib.pl
# Display the icons for various types of lemonldapconfig options
use Data::Dumper;
#require './lemonldap-lib.pl';
sub parse_config_file
{
local($fh, @rv, $line, %dummy);
$fh = $_[0];
$dummy{'line'} = $dummy{'eline'} = $_[1]-1;
$dummy{'file'} = $_[2];
$dummy{'type'} = 0;
$dummy{'name'} = "dummy";
@rv = (\%dummy);
while($line = <$fh>) {
	chop;
	$line =~ s/^\s*#.*$//g;
	if ($line =~ /^\s*<\/(\S+)\s*(.*)>/) {
		# end of a container directive. This can only happen in a
		# recursive call to this function
		$_[1]++;
		last if ($_[3]);
		}
	elsif ($line =~ /^\s*<IfModule\s+(\!?)(\S+)\.c>/i) {
		# start of an IfModule block. Read it, and if the module
		# exists put the directives in this section.
		local ($not, $mod) = ($1, $2);
		local $oldline = $_[1];
		$_[1]++;
		local @dirs = &parse_config_file($fh, $_[1], $_[2], 1);
		if (!$not && $httpd_modules{$mod} ||
		    $not && !$httpd_modules{$mod}) {
			# use the directives..
			push(@rv, { 'line', $oldline,
				    'eline', $oldline,
				    'file', $_[2],
				    'name', "<IfModule $not$mod>" });
			push(@rv, @dirs);
			push(@rv, { 'line', $_[1]-1,
				    'eline', $_[1]-1,
				    'file', $_[2],
				    'name', "</IfModule>" });
			}
		}
	elsif ($line =~ /^\s*<IfDefine\s+(\!?)(\S+)>/i) {
		# start of an IfDefine block. Read it, and if the define
		# exists put the directives in this section
		local ($not, $def) = ($1, $2);
		local $oldline = $_[1];
		$_[1]++;
		local @dirs = &parse_config_file($fh, $_[1], $_[2], 1);
		if (!$not && $httpd_defines{$def} ||
		    $not && !$httpd_defines{$def}) {
			# use the directives..
			push(@rv, { 'line', $oldline,
				    'eline', $oldline,
				    'file', $_[2],
				    'name', "<IfDefine $not$def>" });
			push(@rv, @dirs);
			push(@rv, { 'line', $_[1]-1,
				    'eline', $_[1]-1,
				    'file', $_[2],
				    'name', "</IfDefine>" });
			}
		}
	elsif ($line =~ /^\s*<(\S+)\s*(.*)>/) {
		# start of a container directive. The first member is a dummy
		# directive at the same line as the container
		local(%dir, @members);
		%dir = ('line', $_[1],
			'file', $_[2],
			'type', 1,
			'name', $1,
			'value', $2);
		$dir{'value'} =~ s/\s+$//g;
		$dir{'words'} = &wsplit($dir{'value'});
		$_[1]++;
		@members = &parse_config_file($fh, $_[1], $_[2], 1);
		$dir{'members'} = \@members;
		$dir{'eline'} = $_[1]-1;
		push(@rv, \%dir);
		}
	elsif ($line =~ /^\s*(\S+)\s*(.*)$/) {
		# normal directive
		local(%dir);
		%dir = ('line', $_[1],
			'eline', $_[1],
			'file', $_[2],
			'type', 0,
			'name', $1,
			'value', $2);
		if ($dir{'value'} =~ s/\\$//g) {
			# multi-line directive!
			while($line = <$fh>) {
				chop($line);
				$cont = ($line =~ s/\\$//g);
				$dir{'value'} .= $line;
				$dir{'eline'} = ++$_[1];
				if (!$cont) { last; }
				}
			}
		$dir{'value'} =~ s/\s+$//g;
		$dir{'words'} = &wsplit($dir{'value'});
		push(@rv, \%dir);
		$_[1]++;
		}
	else {
		# blank or comment line
		$_[1]++;
		}
	}
return @rv;
}

# wsplit(string)
# Splits a string like  foo "foo \"bar\"" bazzz  into an array of words
sub wsplit
{
local($s, @rv); $s = $_[0];
$s =~ s/\\\"/\0/g;
while($s =~ /^"([^"]*)"\s*(.*)$/ || $s =~ /^(\S+)\s*(.*)$/) {
	$w = $1; $s = $2;
	$w =~ s/\0/"/g; push(@rv, $w);
	}
return \@rv;
}

# wjoin(word, word, ...)
sub wjoin
{
local(@rv, $w);
foreach $w (@_) {
	if ($w =~ /^\S+$/) { push(@rv, $w); }
	else { push(@rv, "\"$w\""); }
	}
return join(' ', @rv);
}
sub find_handler_in_httpd {

    my $file =shift;
    my $pattern =shift;
open $f,"< $file";
my @l  = parse_config_file ($f) ;
foreach (@l) {
next if $_->{name} !~ /virtualhost/i ;  
my $find;
my @tab = @{$_->{members}} ;
my $ok;
foreach (@tab) {
    next if $_->{value} !~ /handlerid/i ;
    next  if   $_->{words}->[1] !~ /$pattern/i;
    $ok=1;
    last;
   }
if ($ok) {
$find=$_ ;
return $find;
}
}  
    return 0;
}	
sub get_param_httpd {

    my $h =shift;
    return $h->{members} ;
}

1;
#my $res = find_handler("/opt/apache/conf/lemon.conf", 'edito-agent');



#my $t =Dumper ($res);
#print $t;

