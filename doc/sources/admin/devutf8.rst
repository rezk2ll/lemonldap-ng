Handling encoding issues
========================

LemonLDAP::NG has to integrate with many external systems: HTTP servers and
clients, databases, libraries (such as Lasso). At each integration point, it is
crucial to ensure that text data is provided in the right form: text string,
binary string, etc.

Passing an ISO-8859-1 string to a library that expects an UTF-8 string, or the
other way around, will lead to text encoding issues: text will contain odd,
unexpected or sometimes missing characters.

Text string and binary strings
------------------------------

Perl was invented before unicode was popular, therefore, even in modern systems,
Perl assumes that the default character set is ISO-8859-1. Perl is also
weak-typed, which means there is no clear difference between a binary string and
a text string. Therefore, when manipulating variables that contain text, the
developer must be aware of what format the text is supposed to be encoded as in
the current context.

**There is no way to distinguish whether a string contains text of binary data
in Perl**.

Because of this, we needs to have rules to decide if a given variable should
contain text data or binary data.

The Perl documentation recommends to immediately decode binary data to text
strings and manipulate text strings as much as we can.

However, external systems have no notion of text strings (or numbers, or
objects, or cats), computers only understand binary data. Therefore, everytime
you need to communicate with an external system, your text strings must be
encoded to, or decoded from, binary data.

Some libraries expect text strings, and some others expect binary data, sadly
the documentation is not always very clear about that. Some libraries let you
decide with an option.

For example, in Net::LDAP, the ``raw`` option can be used to indicate which
attributes contain binary data. The other attributs will return or expect text
strings. As another example, the ``pg_enable_utf8`` option makes DBI accept and
return text strings and not binary strings (except if the column type is a
binary type).

How to decode/encode data
-------------------------

In order to convert a text string to a binary string ::

    use Encode;

    # Session variables are stored as text strings
    my $title = $req->sessionInfo->{title};

    # Check that your original text string is correct
    $self->p->_dump_string($title);

    # Do not alter the original variable! Copy it and convert it to binary
    # before handing it to the library
    my $binary_title = encode("UTF-8", $title);

    function_of_my_lib($binary_title);

In order to convert a binary string to a text sting ::

    use Encode;

    my $result = function_of_my_lib();

    my $decoded_var = decode("UTF-8", $result);

    # Check that your decoded text string is correct
    $self->p->_dump_string($decoded_var);

    $req->sessionInfo->{title} = $decoded_var;


Checking how Perl understands a string
--------------------------------------

LemonLDAP::NG provides a ``_dump_string`` method that will help you figure out
what a variable contains. It requires the ``logLevel`` to be set to ``debug``.

::

    $self->p->_dump_string($var);
    [debug] $str = "Le\ Grand\ M\N{LATIN SMALL LETTER E WITH ACUTE}chant\ Loup"

You can use this method to verify if Perl has correctly understood the content
of your text strings. 

Note that is you try this method on a binary string, you will get erroneous
results. This is confusing, but expected.
