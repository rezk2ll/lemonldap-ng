|image0|

Find user plugin
================

This plugin allows unauthenticated users to search for an user account to impersonate. This may be useful to randomly provide an
identifier depending on allowed searching attributes and excluded values.

.. attention::

    FindUser plugin works only if :doc:`Impersonation plugin<impersonation>` is enabled.

Configuration
-------------

Just enable it in the Manager (section “plugins”). Then, set searching attributes used for selecting accounts and randomly suggest one of them in login form. Excluding attributes can also be defined to exclude some user accounts and avoid to provide them.

-  **Parameters**:

   -  **Activation**: Enable / Disable this plugin
   -  **Character used as wildcard**: Character that can be used by users as wildcard. An empty value disable wildcarded search requests
   -  **Parameters control**: Regular expression used for checking searching values syntax
   -  **Searching attributes**: For each attribute, you have to set a key (attribute as defined in UserBD) and a value that will be display in login form (placeholder). A value can be a multivalued list separated by multiValuesSeparator parameter (General Parameters > Advanced parameters > Separator). See note below.
   -  **Excluding attributes**: You can defined here attributes used for excluding accounts. Set keys corresponding to UserBD attributes and values to exclude. A value can be a multivalued list separated by multiValuesSeparator parameter (General Parameters > Advanced parameters > Separator)

.. note::

   You can provide a 'multiValuesSeparator' separated list of allowed searching values that will be displayed as an HTML <select> list ::

         attribute#placeholder[#empty] => value1; placeholder1; value2; placeholder2

   For example ::

         uid#Identity   => dwho; Dr Who; rtyler; Rose Tyler; msmith; Mr Smith

         uid#Identity#1 => dwho; Dr Who; rtyler; Rose Tyler (allow empty value)

   Entries are sorted by alphabetical order.

.. attention::

    Searching request is built based on provided parameters value depending on users backend like this:

    request => searchAttr1=value && searchAttr2=value && not excludeAttr1=value && not excludeAttr2=value

.. danger::

    This plugin works only with a users backend and the searching or excluding attributes must exist.

.. danger::

    With AuthChoice, you must set which module will be called by this plugin (:doc:`Backend choice by users<authchoice>`).



.. |image0| image:: /documentation/beta.png
   :width: 100px
