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
   -  **User accounts URL**: User database URL to search on if REST backend is used. Let it blank to use default user data URL.
   -  **Searching attributes**: For each attribute, you have to set a key (attribute as defined in UserBD) and a value that will be display in login form (placeholder). A value can be a multivalued list separated by multiValuesSeparator parameter (General Parameters > Advanced parameters > Separator). Attibutes can be sorted by adding ``#_`` before their name (where ``#`` is a number). See note below. 
   -  **Excluding attributes**: You can defined here attributes used for excluding accounts. Set keys corresponding to UserBD attributes and values to exclude. A value can be a multivalued list separated by multiValuesSeparator parameter (General Parameters > Advanced parameters > Separator)

.. note::

   By default, simple searching attributes are mandatory to restrict the number of entries to return. To set an attribute as optional,
   you can use the following syntax ::

         uid##1  =>  UID

.. note::

   You can provide a 'multiValuesSeparator' separated list of allowed searching values that will be displayed as an HTML <select> list ::

         attribute#placeholder[#empty] => value1; placeholder1; value2; placeholder2

   For example ::

         uid#Identity   => dwho; Dr Who; rtyler; Rose Tyler; msmith; Mr Smith

         uid#Identity#1 => dwho; Dr Who; rtyler; Rose Tyler (allow empty value)

         1_uid#Identity#1 => 2_dwho; Dr Who; 1_rtyler; Rose Tyler; dalek; Dalek 
         (The attributes will be sorted by number, those without a number will appear at the end of the list)


.. attention::

    Searching request is built based on provided parameters value depending on users backend like this:

    request => searchAttr1=value && searchAttr2=value && not excludeAttr1=value && not excludeAttr2=value


.. attention::

    In some cases (like Choice authentication with SSL and Ajax), FindUser Ajax request can be blocked by Content Security Policy.
    
    You may have to allow <Portal>/finduser in CSP ``General Parameters > Advanced Parameters > Security > Content security policy``


.. danger::

    This plugin works only with a users backend and of course if the searching or excluding attributes are existing.

.. danger::

    With AuthChoice, you must set which module will be called by this plugin (:doc:`Backend choice by users<authchoice>`).