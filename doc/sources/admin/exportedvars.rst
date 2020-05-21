Exported variables
==================

Presentation
------------

Exported variables are the variables available to
:doc:`write rules and headers<writingrulesand_headers>`. They are
extracted from the users database by the
:ref:`users module<start-authentication-users-and-password-databases>`.

To create a variable, you've just to map a user attributes in LL::NG
using ``Variables`` » ``Exported variables``. For each variable, The
first field is the name which will be used in rules, macros or headers
and the second field is the name of the user database field.

Examples for :doc:`LDAP<authldap>`:

============= ==============
Variable name LDAP attribute
============= ==============
uid           uid
number        employeeNumber
name          sn
============= ==============

You can define exported variables for each module in the module
configuration itself. Variables defined in the main
``Exported variables`` will be used for each backend. Variables defined
in the exported variables node of the module will be used only for that
module.

|Exported variables in the Manager|


.. tip::

    You can define environment variables in
    ``Exported variables``, this allows one to populate user session with
    some environment values. Environment variables will not be queried in
    users database.

.. _macros_and_groups:

Extend variables using macros and groups
----------------------------------------

Macros and groups are calculated during authentication process by the
portal:

-  macros are used to extend (or rewrite)
   :doc:`exported variables<exportedvars>`. A macro is stored as
   attributes: it can contain boolean results or any string
-  macros can also be used to import environment variables *(these
   variables are in CGI format)*. Example: ``$ENV{HTTP_COOKIE}``
-  groups are stored as a string with values separated by ''; ''
   (default values separator) in the special attribute ``groups``: it
   contains the names of groups whose rules were returned true for the
   current user. For example:

.. code-block:: perl

   $groups = group3; admin

-  You can also get groups in ``$hGroups`` which is a Hash Reference of
   this form:

.. code-block:: perl

   $hGroups = {
             'group3' => {
                           'description' => [
                                              'Service 3',
                                              'Service 3 TEST'
                                            ],
                           'cn' => [
                                     'group3'
                                   ],
                           'name' => 'group3'
                         },
             'admin' => {
                          'name' => 'admin'
                        }
           }

Example for macros:

.. code-block:: perl

   # boolean macro
   isAdmin -> $uid eq 'foo' or $uid eq 'bar'
   # other macro
   displayName -> $givenName." ".$surName

.. |Exported variables in the Manager| image:: /documentation/manager-exported-variables.png
   :class: align-center

