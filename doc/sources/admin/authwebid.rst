WebID
=====

============== ===== ========
Authentication Users Password
============== ===== ========
✔              ✔
============== ===== ========

Presentation
------------

`WebID <http://www.w3.org/wiki/WebID>`__ is a way to uniquely identify a
person, company, organisation, or other agent using a URI and a
certificate.

You need `Web::ID <https://metacpan.org/release/Web-ID>`__ package.

Configuration
-------------

In Manager, go in ``General Parameters`` > ``Authentication modules``
and choose WebID for authentication module. You can also use WebID as
user database.

Then, go in ``WebID parameters``:

-  **Authentication level**: authentication level for this module.
-  **WebID whitelist**: list of space separated hosts granted to host
   FOAF document. You can use '*' character. Example :``*.partner.com``

If you use WebID as user database, declare values in **exported
variables** :

-  use any key name you want. If you want to refuse access when a data
   is missing, just add a "!" before the key name
-  in the value field, set the field name. Take a look at
   http://xmlns.com/foaf/spec/#sec-crossref. Example
   :``name => foaf:name``

See also :doc:`exported variables configuration<exportedvars>`.

Apache configuration
~~~~~~~~~~~~~~~~~~~~

Portal host must be configured to use SSL and must ask for client
certificate. It is recommended to use optional_no_ca since WebID doesn't
use certificate authorities :

.. code-block:: apache

   <VirtualHost _default_:443>
   ServerName auth.example.com
   SSLEngine on
   SSLCertificateFile ...
   SSLCertificateKeyFile ...
   SSLVerifyClient optional_no_ca
   ...
   </VirtualHost>

Tests
~~~~~

To test this, you can build your own WebID certificate using one of :

-  `Web::ID::Certificate::Generator <https://metacpan.org/module/Web::ID::Certificate::Generator>`__
-  `my-profile.eu <https://my-profile.eu/>`__
-  `gen-webid-cert.sh <https://gist.github.com/njh/2432427>`__
