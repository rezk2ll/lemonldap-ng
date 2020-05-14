
my $var;
{
    local $/;
    $var = <STDIN>;
}

# Fix {}
$var =~ s/(\{\w*\})/<nowiki>\1<\/nowiki>/g;
print $var
