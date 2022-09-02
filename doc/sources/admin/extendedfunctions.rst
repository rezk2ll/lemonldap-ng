Extended functions
==================

Presentation
------------

When :doc:`writing rules and headers<writingrulesand_headers>`, you can
use Perl expressions that will be evaluated in a jail, to prevent bad
code execution.

This is also true for:

-  :ref:`Menu modules activation rules<portalmenu-menu-modules>`
-  :doc:`Form replay data<formreplay>`
-  Macros
-  Issuer databases use rules
-  etc.

Inside this jail, you can access to:

* All session values and CGI environment variables (through `$ENV{<HTTP_NAME>}`)
* Core Perl subroutines (split, pop, map, etc.)
* :doc:`Custom functions<customfunctions>`
* The `encode_base64 <http://perldoc.perl.org/MIME/Base64.html>`__ subroutine
* Information about current request
* Extended functions except basic, iso2unicode and unicode2iso:

  * basic_
  * checkDate_
  * checkLogonHours_
  * date_
  * dateToTime_ (|new| in version 2.0.12)
  * encrypt_
  * groupMatch_
  * has2f_ (|new| in version 2.0.10)
  * inGroup_ (|new| in version 2.0.8)
  * isInNet6_
  * iso2unicode_
  * iso2unicodeSafe_ (|new| in version 2.0.15)
  * listMatch_ (|new| in version 2.0.7)
  * token_
  * unicode2iso_
  * unicode2isoSafe_ (|new| in version 2.0.15)
  * varIsInUri_ (|new| in version 2.0.7)


.. |new| image:: /documentation/new.png
   :width: 35px

.. tip::

    To know more about the jail, check `Safe module
    documentation <http://perldoc.perl.org/Safe.html>`__.

Extended Functions List
-----------------------

basic
~~~~~

.. attention::

    This function is not compliant with the :doc:`Safe jail<safejail>`,
    you will have to disable the jail to use it.

This function builds the ``Authorization`` HTTP header employed in
:doc:`HTTP Basic authentication scheme<applications/authbasic>`. It will
convert `user` and `password` parameters from UTF-8 to ISO-8859-1.

Functions parameters:

-  **user**
-  **password**

Simple usage example:

::

   basic($uid,$_password)

checkDate
~~~~~~~~~

This function checks date of current request, and compare it to
a start date and an end date. It returns 1 if this matches, 0 else.


The date format corresponds to LDAP date syntax, for example for the 1st of March
2009 (GMT)

::

   20090301000000Z

|new| Since version 2.0.12, the date may end with a differential timezone, 
for example for the 1st of March 2009 (+0100):

::

    20090301000000+0100


Functions parameters:

-  **start**: Start date (GMT unless, |new| since version 2.0.12, a
   differential timezone is included)
-  **end**: End date (GMT unless, |new| since version 2.0.12, a
   differential timezone is included)
-  **default_access** (optional): Which result to return if **start** and
   **end** dates are empty

Simple usage example:

::

   checkDate($ssoStartDate, $ssoEndDate)

checkLogonHours
~~~~~~~~~~~~~~~

This function checks the day and the hour of current request, and
compare it to allowed days and hours. It returns 1 if matches, 0
else. By default, the allowed days and hours is an hexadecimal
value, representing each hour of the week. A day has 24 hours, and a
week 7 days, so the value contains 168 bits, converted into 42
hexadecimal characters. Sunday is the first day.

For example, for a full access, excepted week-end:

::

   000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000


.. tip::

    You can use the binary value from the logonHours attribute of Active
    Directory, or create a custom attribute in your LDAP schema.

Function parameters:

-  **logon_hours**: String representing allowed logon hours (GMT)
-  **syntax** (optional): ``hexadecimal`` (default) or ``octetstring``
-  **time_correction** (optional): Hours to add or to subtract
-  **default_access** (optional): Which result to return if
   **logon_hours** is empty

Simple usage example:

::

   checkLogonHours($ssoLogonHours)

If you use the binary value (Active Directory), use this:

::

   checkLogonHours($ssoLogonHours, 'octetstring')

You can also configure jetlag (if all of your users use the same
timezone):

::

   checkLogonHours($ssoLogonHours, '', '+2')

If you manage different timezones, you have to take the jetlag into
account in ssoLogonHours values, or use the $_timezone parameter. This
parameter is set by the portal and use javascript to get the connected
user timezone. It should works on every browser:

::

   checkLogonHours($ssoLogonHours, '', $_timezone)

You can modify the default behavior for people without value in
ssoLogonHours. Indeed, by default, users without logon hours values are
rejected. You can allow these users instead of reject them:

::

   checkLogonHours($ssoLogonHours, '', '', '1')

date
~~~~

Returns the date, in format YYYYMMDDHHMMSS, local time by default, GMT
by calling ``date(1)``

::

    For example: date(1) lt '19551018080000'

dateToTime
~~~~~~~~~~

.. versionadded:: 2.0.12

Used for converting a string date into epoch time.

The date format is the LDAP date syntax, for example for the 1st March
2009 (GMT):

::

    20090301000000Z

The date may end with a differential timezone that is interpreted to 
adjust the epoch time, for example for the 1st March 2009 (+0100):

::

    20090301000000+0100

Simple usage example:

::

    dateToTime($ssoStartDate) lt dateToTime(date(1))

encrypt
~~~~~~~

.. tip::

    Since version 2.0, this function is now compliant with
    :doc:`Safe jail<safejail>`.

This function uses the secret key of LL::NG configuration to crypt a data.
This can be used for anonymizing identifier given to the protected
application.

::

   encrypt($_whatToTrace)

groupMatch
~~~~~~~~~~

This function allows one to parse the ``$hGroups`` variable to check if
a value is present inside a group attribute.

Function parameter:

-  **groups**: ``$hGroups`` variable
-  **attribute**: Name of group attribute
-  **value**: Value to check

Simple usage example:

::

   groupMatch($hGroups, 'description', 'Service 1')


.. _has2f:

has2f
~~~~~

.. versionadded:: 2.0.10

This function tests if the current user has registered a second factor. The following types are supported out of the box:

* :doc:`TOTP<totp2f>`
* :doc:`U2F<u2f>`
* :doc:`UBK<yubikey2f>`
* :doc:`WebAuthn<webauthn2f>`

Example::

   has2f()
   has2f('UBK')
   has2f('UBK') or has2f('TOTP')


.. warning::

   Do **NOT** use this test to check if the user has **used** their second factor for logging in!
   This test only checks if the user has registered a second factor. Regardless of their **current**
   authentication level. It can be used to simplify second factor activation rules.


.. note::

   Before version 2.0.10, you need to use the following syntax ::

      $_2fDevices =~ /"type":\s*"TOTP"/s

inGroup
~~~~~~~

.. versionadded:: 2.0.8

This function lets you test if the user is in a given group. It is
case-insensitive.

Usage example:

::

   inGroup('admins')

   inGroup('test users')

The function returns 1 if the user belongs to the given group, and 0 if
they don't.

isInNet6
~~~~~~~~

Function to check if an IPv6 address is in a subnet. Example *check if
IP address is local*:

.. code-block:: perl

   isInNet6($ipAddr, 'fe80::/10')

iso2unicode
~~~~~~~~~~~

.. attention::

    This function is not compliant with :doc:`Safe jail<safejail>`.
    You will have to disable the jail to use it.

This function converts a string from ISO-8859-1 to UTF-8.

Function parameter:

-  **string**

Simple usage example:

::

   iso2unicode($name)

iso2unicodeSafe
~~~~~~~~~~~~~~~

This function converts a string from ISO-8859-1 to UTF-8
but it is not as portable as the original one.

Functions parameters:

-  **string**

Simple usage example:

::

   iso2unicodeSafe($name)

.. _listMatch:

listMatch
~~~~~~~~~

.. versionadded:: 2.0.7

This function lets you test if a particular value can be found with a
multi-valued session attribute.

Function parameter:

-  **list**: Variable containing several values (plain string with
   separator, array or hash)
-  **value**: Value to search in the list
-  **ignorecase**: Ignore case, by default the search is case-sensitive

Simple usage example:

::

   # Case sensitive match
   listMatch($roles, 'role-app1')

   # Case insensitive match
   listMatch($roles, 'RoLe-aPp1', 1)

The function returns 1 if the value was found, and 0 if it was not
found.

token
~~~~~

This function generates token used for
:doc:`handling server webservice calls<servertoserver>`.

::

   token($_session_id,'webapp1.example.com','webapp2.example.com')

varIsInUri
~~~~~~~~~~

.. versionadded:: 2.0.7

Function to check if a variable is in requested URI

Example *check if $uid is in /check-auth/ URI*:

.. code-block:: perl

   varIsInUri($ENV{REQUEST_URI}, '/check-auth/', $uid)

   https://test1.example.com/check-auth/dwho     -> true
   https://test1.example.com/check-auth/dwho/api -> true
   https://test1.example.com/check-auth/dwh      -> false

\* You can set "restricted" flag to match exact URI:

.. code-block:: perl

   varIsInUri($ENV{REQUEST_URI}, '/check-auth/', "$uid/", 1)

   https://test1.example.com/check-auth/rtyler/     -> true
   https://test1.example.com/check-auth/rtyler/api  -> false
   https://test1.example.com/check-auth/rtyler      -> false

.. |image0| image:: /documentation/new.png
   :width: 35px
.. |image1| image:: /documentation/new.png
   :width: 35px

unicode2iso
~~~~~~~~~~~

.. attention::

    This function is not compliant with :doc:`Safe jail<safejail>`.
    You will have to disable the jail to use it.

This function convert a string from UTF-8 to ISO-8859-1.

Function parameter:

-  **string**

Simple usage example:

::

   unicode2iso($name)

unicode2isoSafe
~~~~~~~~~~~~~~~

This function convert a string from UTF-8 to ISO-8859-1
but it is not as portable as the original one.

Function parameter:

-  **string**

Simple usage example:

::

   unicode2isoSafe($name)
