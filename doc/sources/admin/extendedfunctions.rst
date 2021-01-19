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

* all session values and CGI environment variables (through `$ENV{<HTTP_NAME>}`)
* Core Perl subroutines (split, pop, map, etc.)
* :doc:`Custom functions<customfunctions>`
* The `encode_base64 <http://perldoc.perl.org/MIME/Base64.html>`__ subroutine
* Information about current request
* Extended functions:

  * basic_
  * checkDate_
  * checkLogonHours_
  * date_
  * encrypt_
  * groupMatch_
  * has2f_ (|new| in version 2.0.10)
  * inGroup_ (|new| in version 2.0.8)
  * isInNet6_
  * iso2unicode_
  * listMatch_ (|new| in version 2.0.7)
  * token_
  * unicode2iso_
  * varIsInUri_ (|new| in version 2.0.7)


.. |new| image:: /documentation/new.png
   :width: 35px

.. tip::

    To know more about the jail, check `Safe module
    documentation <http://perldoc.perl.org/Safe.html>`__.

Extended Functions List
-----------------------

date
~~~~

Returns the date, in format YYYYMMDDHHMMSS, local time by default, GMT
by calling ``date(1)``

::

    For example: date(1) lt '19551105080000'

checkLogonHours
~~~~~~~~~~~~~~~

This function will check the day and the hour of current request, and
compare it to allowed days and hours. It returns 1 if this match, 0
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

Functions parameters:

-  **logon_hours**: string representing allowed logon hours (GMT)
-  **syntax** (optional): ``hexadecimal`` (default) or ``octetstring``
-  **time_correction** (optional): hours to add or to subtract
-  **default_access** (optional): what result to return if
   **logon_hours** is empty

Simple usage example:

::

   checkLogonHours($ssoLogonHours)

If you use the binary value (Active Directory), use this:

::

   All e
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

checkDate
~~~~~~~~~

This function will check the date of current request, and compare it to
a start date and an end date. It returns 1 if this match, 0 else.


The date format is the LDAP date syntax, for example for the 1st March
2009:

::

   20090301000000Z

Functions parameters:

-  **start**: Start date (GMT)
-  **end**: End date (GMT)
-  **default_access** (optional): what result to return if **start** and
   **end** are empty

Simple usage example:

::

   checkDate($ssoStartDate, $ssoEndDate)

basic
~~~~~


.. attention::

    This function is not compliant with
    :doc:`Safe jail<safejail>`, you will need to disable the jail to use
    it.

This function builds the ``Authorization`` HTTP header used in
:doc:`HTTP Basic authentication scheme<applications/authbasic>`. It will
force conversion from UTF-8 to ISO-8859-1 of user and password data.

Functions parameters:

-  **user**
-  **password**

Simple usage example:

::

   basic($uid,$_password)

unicode2iso
~~~~~~~~~~~


.. attention::

    This function is not compliant with
    :doc:`Safe jail<safejail>`, you will need to disable the jail to use
    it.

This function convert a string from UTF-8 to ISO-8859-1.

Functions parameters:

-  **string**

Simple usage example:

::

   unicode2iso($name)

iso2unicode
~~~~~~~~~~~


.. attention::

    This function is not compliant with
    :doc:`Safe jail<safejail>`, you will need to disable the jail to use
    it.

This function convert a string from ISO-8859-1 to UTF-8.

Functions parameters:

-  **string**

Simple usage example:

::

   iso2unicode($name)

groupMatch
~~~~~~~~~~

this function allows one to parse the ``$hGroups`` variable to check if
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

This function tests if the current user has registered a second factor. The following types are supported:

* :doc:`TOTP<totp2f>`
* :doc:`U2F<u2f>`
* :doc:`UBK<yubikey2f>`

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

encrypt
~~~~~~~


.. tip::

    Since version 2.0, this function is now compliant with
    :doc:`Safe jail<safejail>`.

This function uses the secret key of LLNG configuration to crypt a data.
This can be used for anonymizing identifier given to the protected
application.

::

   encrypt($_whatToTrace)

token
~~~~~

This function generates token used for
:doc:`handling server webservice calls<servertoserver>`.

::

   token($_session_id,'webapp1.example.com','webapp2.example.com')

isInNet6
~~~~~~~~

Function to check if an IPv6 address is in a subnet. Example *check if
IP address is local*:

.. code-block:: perl

   isInNet6($ipAddr, 'fe80::/10')

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
