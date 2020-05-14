
sub indent {
    my $tag = shift || " important";
    $tag = " note" if $tag  eq " info";
    my $text = shift;
    $text =~ s/^ *//;
#    $text =~ s/\n(?!(\n|\.|-|$))/ /sg;
    $text =~ s/^/    /mg;
    return "\n..${tag}:: \n\n".$text;
}

my $var;
{
    local $/;
    $var = <STDIN>;
}

# Handle admonitions
$var =~ s/<note([^>]*)>(.*?)<\/note>/indent($1,$2)/ges;

# Make image urls absolute
#$var =~ s/image:: \//image:: /g;

# Handle new.png
$var =~ s/image:: \.\.\/new/image:: \/documentation\/new/g;

# Remove ::: syntax
$var =~ s/::://g;
print $var
