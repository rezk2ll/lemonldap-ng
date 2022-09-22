Rules examples
==============

This page contains a few useful Perl expressions you can use in your
:ref:`Handler rules<rules>`, SAML/OIDC/CAS security
rules, 2FA Activation rules, etc.

Using session attributes
------------------------

Session attributes are visible in the Manager's Session browser, any
attribute you see there can be used in a rule!

-  Restricting access to a single user:

::

   $uid eq "dwho"
   $uidNumber == 1000
   $cn eq "Doctor Who"
   $email eq "dwho@badwolf.org"
   etc.


.. tip::

    In Perl, ``eq`` means *Equal* and must be used on strings.
    ``==`` should be used only on numbers

.. danger::

    In Perl, ``@`` character means an array and ``%`` a hash!
    If you want to write a macro with these characters, you have to escape them like this:

::

    $my_email = "$uid\@my-domain.com"
    $percent = "$rate\%more"

-  Restricting access to specific groups

::

   $groups =~ /\b(?:admins|su)\b/ # admins OR su
   $groups =~ /\badmin_[1-3a]\b/ # admin_1 OR admin_2 OR admin_3 OR admin_a

   defined $hGroups->{'administrators'}

   # 2.0.8 and higher only
   inGroup('administrators')

-  Combining multiple expressions

::

   inGroup('timelords') and not $uid eq 'missy'

-  Using Perl's regular expressions

::

   $cn =~ /^Doctor.*/i
   $email !~ /\@spam.com$/

-  Filtering on Authentication Level

::

   $authenticationLevel >= 3

-  Filtering on Authentication method

::

   $_auth ne 'Demo'

-  Checking if the user has a an **available** second factor.

::

   # Since 2.0.10
   has2f()
   has2f('TOTP')
   has2f('TOTP') or has2f('U2F')

   # Before 2.0.10
   $_2fDevices =~ /"type":\s*"TOTP"/s

.. tip::

    In Perl, ``ne`` means *Not Equal* and must be used on
    strings. ``\b`` means *word Boundary*. (?:) means *non capturing*
    parenthesis.


Using environment variables
---------------------------

-  Comparing the IP address

::

   $env->{REMOTE_ADDR} =~ /^10\./

-  Comparing requested URI

::

   $env->{REQUEST_URI} =~ /test/

