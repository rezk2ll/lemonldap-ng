Check DevOps plugin
===================

This plugin can be used to check a :doc:`DevOps<devopshandler>` file.

Configuration
-------------

Just enable it in manager (“plugins” section).

-  **Parameters**:

   -  **Activation**: enable/disable this plugin
   -  **Download file**: Allow users to download DevOps file from a
      remote server by providing an URL
      (By example: http://myapp.example.com:8080). Plugin will
      try to retrieve remote file by sending a request
      (i.e. http://myapp.example.com:8080/rules.json)
   -  **Display normalized headers**: display headers as they are sent
   -  **Check session attributes**: check if used attributes exist

Usage
-----
When enabled, ``/checkdevops`` URL path is handled by this plugin.
Then, you can paste a file to test your rules and headers or
provide an URL to download the ``rules.json`` file.

Example
~~~~~~~
DevOps handler requires a rules.json file to define access rules and headers:

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

.. note::

    This plugin displays ALL user session attributes except the hidden ones.

    You have to restrict access to specific users like DevOps teams
    by setting an access rule like other VirtualHosts.

    By example: ``$groups =~ /\bdevops\b/``

.. danger::

    Be careful to not display secret attributes.

    checkDevOps plugin takes hidden attributes into account.
