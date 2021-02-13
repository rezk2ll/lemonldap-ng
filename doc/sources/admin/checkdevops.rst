Check DevOps plugin
===================

This plugin can be used to check the :doc:`DevOps<devopshandler>` file.

Configuration
-------------
Just enable it in the manager (section “plugins”).

Usage
-----
When enabled, ``/checkdevops`` URL path is handled by this plugin.
Then, you can paste a file to test your rules and headers.

Example
~~~~~~~
DevOps handler requires a rules.json file to define
access rules and headers:

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

    This plugin displays ALL user session attributes except
    the hidden ones.

    You have to restrict access to specific users like DevOps teams
    by setting an access rule like other VirtualHosts.

    By example: ``$groups =~ /\bdevops\b/``

.. attention::

    Be careful to not display secret attributes.

    checkDevOps plugin uses hidden attributes option.