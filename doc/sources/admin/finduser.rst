|image0|

FindUser plugin
===============

This plugin allows unauthenticated users to search for an user account to impersonate. This may be useful to randomly provide an
identifier depending on allowed searching attributes.

.. attention::

    FindUser plugin works only if :doc:`Impersonation plugin<impersonation>` is enabled.

Configuration
-------------

Just enable it in the Manager (section “plugins”). Then, set searching attributes used for selecting accounts and randomly suggest one of them in login form. Excluding attributes can also be defined to exclude some user accounts and avoid to provide them.

-  **Parameters**:

   -  **Activation**: Enable/disable this plugin.
   -  **Character used as wildcard**: Character that can be used by users as wildcard. An empty value disable wildcarded search requests.
   -  **Parameters control**: Regular expression used for checking searching values syntax.
   -  **Searching attributes**: For each attribute, you have to set a key (attribute as defined in UserBD) and a value that will be display in login form (placeholder). 
   -  **Excluding attributes**: You can defined here attributes used for excluding accounts. Set keys corresponding to UserBD attributes
   and values to exclude. A value can be a multivalued list separated by multiValueSeparator parameter (General Parameters > Advanced parameters > Separator)

.. attention::

    Searching request is built based on provided parameters value depending on users backend like this:

    request => searchAttr1=value && searchAttr2=value && not excludeAttr1=value && not excludeAttr2=value

.. danger::

    Of course, searching and excluding attributes must exist in user backend.


.. |image0| image:: /documentation/beta.png
   :width: 100px