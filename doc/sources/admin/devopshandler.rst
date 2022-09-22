DevOps Handler
==============

This Handler is designed to retrieve VHost configuration from the website
itself, not from LL:NG configuration. Rules and headers are set in a
**rules.json** file stored at the website root directory (ie
``http://website/rules.json``). This file looks like:

.. code-block:: json

   {
     "rules": {
       "^/admin": "$uid eq 'admin'",
       "default": "accept"
     },
     "headers": {
       "Auth-User": "$uid"
     }
   }

If this file is not found, the default rule "accept" is applied and just
"Auth-User" header is sent (Auth-User => $uid).

No specific configuration is required except that:

-  you have to select ``DevOps`` handler type either with
   ``VHOSTTYPE`` environment variable or in VHost options
-  you can set in VHost options the loopback URL requested by 
   the DevOps handler to retrieve ``/rules.json`` or use
   ``RULES_URL`` environment variable to set JSON file location.
   Default to ``http://127.0.0.1:<server-port>``
-  HTTPS or redirection port can be set by using
   ``HTTP_REDIRECT`` or ``PORT_REDIRECT`` environment variables.


.. attention::

    Note that DevOps handler will not compile
    rules.json if :doc:`Safe Jail<safejail>` is not enabled.

See :doc:`SSO as a Service<ssoaas>` for more.
