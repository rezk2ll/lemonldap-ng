Slave
=====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------

LL::NG Slave backend relies on HTTP headers to retrieve user login
and/or attributes.

-  Authentication: will check user login in a header and create session
   without prompting any credentials (but will register client IP and creation date)
-  Users: collect data transferred in HTTP headers by the "master".

It allows one to put LL::NG::portal behind another web SSO, or behind a
SSL hardware to delegate SSL authentication to that hardware.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose Slave for authentication or users module.

Then, go in ``Slave parameters``:

-  **Authentication level**: authentication level for this module
-  **Header for user login**: header containing user main login
-  **Display authentication logo**: display Slave logo


Security
^^^^^^^^

-  **Master's IP address**: IP addresses of servers which are accredited to authenticate user.
   This is a security point to prevent someone to create a session by sending custom headers.
   You can set netblocks in CIDR notation or list IP addresses, space or comma separated.
   By example: ``127.0.0.2, 192.168.1.1 10.20.30.0/24``. A blank value disables this checking.
-  **Extracted certificate field**: must be set to the Apache/Nginx environment variable
   containing the ``cn`` attribute. A blank value disables this checking.
-  **Regexp to test extracted certificate field**: regular expression used for testing client certificate ``cn``
-  **Control header name**: header containing value to check.
   A blank value disables this checking.
-  **Control header content**: value to check. A blank value disables this checking.


Exported Variables
^^^^^^^^^^^^^^^^^^

You have then to declare HTTP headers exported by the main SSO. Example :

================= ========================
Key (LL::NG name) Value (HTTP header name)
================= ========================
uid               Auth-User
mail              User-Email
================= ========================

Example
~~~~~~~

-  Request with curl (AuthChoice with Slave and Secured cookie => double
   cookies for a single session):

**Control header name**: control

**Control header content**: password

::

   curl -k https://127.0.0.1:19876 -H 'CN: dwho' -H 'Host: auth.example.com' -H 'Accept: application/json' -H 'control: password' -d "lmAuth=2_Slave" | json_pp

-  Response for good authentication:

.. code-block:: javascript

   {
       "result" : 1,
       "error" : 0,
       "id_http" : "5237ce20290d6110915a05d62f52618955b5f71b6dd3424481372ad419a5b122",
       "id" : "16fec9bd7a0523328568ca919ee0a6d6e329832f6c302bf36b106db92b5ec23d"
   }

See also :doc:`exported variables configuration<exportedvars>`.
