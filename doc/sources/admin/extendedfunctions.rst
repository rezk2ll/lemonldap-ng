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
* Information about current request
* Extended functions except iso2unicode and unicode2iso:

  * basic_
  * checkDate_
  * checkLogonHours_
  * date_
  * dateToTime_
  * decrypt_
  * encrypt_
  * encode_base64_
  * groupMatch_
  * has2f_
  * inDomain_
  * inGroup_
  * inSubnet_
  * ipInSubnet_
  * isInNet6_
  * iso2unicode_
  * listMatch_
  * subjectid_
  * token_
  * unicode2iso_
  * varIsInUri_
  * bin2guid_
  * guid2bin_


.. tip::

    To know more about the jail, check `Safe module
    documentation <https://perldoc.perl.org/Safe.html>`__.

Extended Functions List
-----------------------

basic
~~~~~

This function builds the ``Authorization`` HTTP header employed in
:doc:`HTTP Basic authentication scheme<applications/authbasic>`. It will
convert `user` and `password` parameters from UTF-8 to ISO-8859-1.

Functions parameters:

-  **user**
-  **password**
-  **use_iso** (optional): whether to encode the result as ISO-8859-1 instead of UTF-8

Simple usage example:

::

   basic($uid,$_password)

   basic($uid,$_password, 1)

checkDate
~~~~~~~~~

This function checks date of current request, and compare it to
a start date and an end date. It returns 1 if this matches, 0 else.


The date format corresponds to LDAP date syntax, for example for the 1st of March
2009 (GMT)

::

   20090301000000Z

The date may end with a differential timezone,
for example for the 1st of March 2009 (+0100):

::

    20090301000000+0100


Functions parameters:

-  **start**: Start date (GMT unless, a differential timezone is included)
-  **end**: End date (GMT unless, a differential timezone is included)
-  **default_access** (optional): Which result to return if **start** and **end** dates are empty

Simple usage example:

::

   checkDate($ssoStartDate, $ssoEndDate)

.. _checkLogonHours:

checkLogonHours
~~~~~~~~~~~~~~~

This function checks the day and the hour of current request, and compare it to
allowed days and hours. It returns 1 if matches, 0 else. The allowed days and
hours are stored in your backend as the hexadecimal representation of a
bit-string, with each bit representing each hour of the week. A day has 24
hours, and a week 7 days, so the value contains 168 bits, converted into 42
hexadecimal characters.  Sunday is the first day. Access is checked against UTC
time, and hexadecimal values should assume big-endian order.

For example, to allow access from 06:00 UTC to 19:00 UTC, every week day

::

    Bit string for weekends:
    00000000 00000000 00000000 => 00 00 00

    Bit string for weekdays:
    00000011 11111111 11100000 => 03 FF E0

    Final hex value:
    00000003FFE003FFE003FFE003FFE003FFE0000000


.. tip::

    If you are using Active Directory, you can simply add the ``logonHours``
    attribute in your list of exported attributes, and use it with this
    function directly::

        checkLogonHours($logonHours)

Function parameters:

-  **logon_hours**: String representing allowed logon hours (GMT)
-  **syntax** (deprecated): value is ignored
-  **time_correction** (optional): Hours to add or to subtract
-  **default_access** (optional): Which result to return if
   **logon_hours** is empty

Simple usage example:

::

   checkLogonHours($ssoLogonHours)

If you want to offset the allowed hours configuration to take timezones into
account, you can specify it as the third argument.

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

decrypt
~~~~~~~

This function uses the secret key of LemonLDAP::NG configuration to decrypt a value.

::

   decrypt($_password)

encrypt
~~~~~~~

This function uses the secret key of LemonLDAP::NG configuration to crypt a data.
This can be used for anonymizing identifier given to the protected
application.

::

   encrypt($_whatToTrace)

encode_base64
~~~~~~~~~~~~~

This function encodes a provided string as Base64

Function parameters:

-  **text**: text to encode
-  **use_iso** (optional): whether to encode the result as ISO-8859-1 instead of UTF-8

::

   encode_base64($myvar)

   encode_base64($myvar, 1)

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


This function tests if the current user has registered a second factor. The following types are supported out of the box:

* :doc:`TOTP<totp2f>`
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


inDomain
~~~~~~~~


This function tests if the request's hostname (HTTP ``Host`` header) belongs to a given DNS domain

Usage example:

::

   inDomain('example.com')

The function returns 1 if the targeted Vhost is equal to the given domain or contains it as a suffix.

inGroup
~~~~~~~


This function lets you test if the user is in a given group. It is
case-insensitive.

Usage examples:

::

   inGroup('admins')

   inGroup('test users')

   inGroup('test users', 'admins')

The function returns 1 if the user belongs to the given group, and 0 if they don't.

inSubnet
~~~~~~~~


This function lets you test if the request's IP address (``REMOTE_ADDR``
environment variable) belongs to a certain subnet. You can give multiple subnets.

Usage examples:

::

   inSubnet('127.0.0.0/8')

   inSubnet('10.0.0.0/8', '192.168.0.0/16')

The function returns 1 if the user's IP is in provided subnets, and 0 if it is not.

isInNet6
~~~~~~~~

Function to check if an IPv6 address is in a subnet. Example *check if
IP address is local*:

.. code-block:: perl

   isInNet6($ipAddr, 'fe80::/10')

ipInSubnet
~~~~~~~~~~


This function lets you test if the provided IP address belongs to a certain
subnet. You can give multiple subnets.

Usage examples:

::

   ipInSubnet($env->{REMOTE_ADDR}, '127.0.0.0/8')

   ipInSubnet($env->{REMOTE_ADDR}, '10.0.0.0/8', '192.168.0.0/16')

The function returns 1 if provided IP is in one of the subnets, and 0 if
it is not.

iso2unicode
~~~~~~~~~~~

This function converts a string from ISO-8859-1 to UTF-8
but it is not as portable as the original one.

Functions parameters:

-  **string**

Simple usage example:

::

   iso2unicodeSafe($name)

iso2unicodeSafe
~~~~~~~~~~~~~~~

Same as ``iso2unicode``


.. _listMatch:

listMatch
~~~~~~~~~


This function lets you test if a particular value can be found with a
multi-valued session attribute.

Function parameter:

-  **list**: Variable containing several values (plain string with separator, array or hash)
-  **values**: Values to search in the list
-  **ignorecase**: Ignore case, by default the search is case-sensitive

Simple usage example:

::

   # Case sensitive match
   listMatch($roles, 'role-app1')
   listMatch($roles, 'role-app1', 'Role-App2')

   # Case insensitive match
   listMatch($roles, 'RoLe-aPp1', 1)
   listMatch($roles, 'RoLe-aPp1', 'Role-App2', 1)

The function returns 1 if a value was found, and 0 if it was not found.

.. _subjectid:

subjectid
~~~~~~~~~


This function lets you generate an identifier suitable with the requirements of `urn:oasis:names:tc:SAML:profiles:subject-id <https://docs.oasis-open.org/security/saml-subject-id-attr/v1.0/cs01/saml-subject-id-attr-v1.0-cs01.html>`__

It takes an optional salt that makes it suitable for pairwise IDs as well.

.. warning::

    The generated ID will only be as stable as the underlying attribute

Function parameter:

-  **value**: Value to hash
-  **scope**: DNS suffix to append
-  **salt**: optional salt to be added at the end of the value before hashing

Simple usage example:

::

   # Generate a subject-id from uid, in a global macro
   subjectid($uid, "scope.edu", "myglobalsalt")

   # Generate a pairwise-id, in a per-service macro
   subjectid($uid, "scope.edu", "myservice")


token
~~~~~

This function generates token used for
:doc:`handling server webservice calls<servertoserver>`.

.. code-block:: perl

   token($_session_id, 'app1.example.com', 'apptest.example.com', '/^webapp[23]\.example\.com/')

.. attention::

    The colon character is not allowed in regexp.



varIsInUri
~~~~~~~~~~


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

unicode2iso
~~~~~~~~~~~

This function convert a string from UTF-8 to ISO-8859-1

Function parameter:

-  **string**

Simple usage example:

::

   unicode2isoSafe($name)

unicode2isoSafe
~~~~~~~~~~~~~~~

Legacy alias for `unicode2iso`

bin2guid
~~~~~~~~

This function convert a binary value representing a GUID to a textual
representation

Function parameter:

-  **string**

Simple usage example:

::

   bin2guid($binvalue)

guid2bin
~~~~~~~~

This function convert a textual GUID representation to a binary value

Function parameter:

-  **string**

Simple usage example:

::

   guid2bin($objectGuid)
