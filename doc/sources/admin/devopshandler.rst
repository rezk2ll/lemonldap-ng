DevOps Handler
==============

This handler is designed to read vhost configuration from the website
itself not from LL:NG configuration. Rules and headers are set in a
**rules.json** file stored at the website root directory (ie
``<nowiki>http://website/rules.json</nowiki>``). This file looks like:

.. code:: json

   {
     "rules": {
       "^/admin": "$uid eq 'admin'",
       "default": "accept'
     },
     "headers": {
       "Auth-User": "$uid"
     }
   }

If this file is not found, the default rule "accept" is applied and just
"Auth-User" header is sent (Auth-User => $uid).

No specific configuration is required except that:

-  you have to choose this specific handler *(directly by using
   ``VHOSTTYPE`` environment variable)*
-  you can set the loopback URL needed by the DevOps handler to get
   ``/rules.json`` or use ``RULES_URL`` parameter to set JSON file path
   *(see :doc:`SSO as a Service<ssoaas>`)*. Default to
   ``<nowiki>http://127.0.0.1:<server-port></nowiki>``


.. important:: 

    Note that DevOps handler will refuse to compile
    rules.json if :doc:`Safe Jail<safejail>` isn't enabled.

See :doc:`SSO as a Service<ssoaas>` for more
