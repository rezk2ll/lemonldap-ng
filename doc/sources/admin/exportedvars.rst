Exported variables
==================

Presentation
------------

Exported variables are the variables available to
:doc:`write rules and headers<writingrulesand_headers>`. They are
extracted from the users database by the
:ref:`users module<start-authentication-users-and-password-databases>`.

To create a variable, you've just to map a user attributes in LL::NG
using ``Variables`` » ``Exported variables``. For each variable, the
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

Macros and groups are computed during authentication process by the
Portal:

-  macros are used to extend (or rewrite)
   :doc:`exported variables<exportedvars>`. A macro is stored as
   attributes: it can contain boolean results or any string
-  macros can also be used for importing environment variables *(these
   variables are in CGI format)*. Example: ``$ENV{HTTP_COOKIE}``
-  groups are stored as a string with values separated by '; '
   (default multivalues separator) in the special attribute ``groups``: it
   contains names of groups whose rules were returned true for the
   current user. For example:

.. danger::

    Macros can be used for rewriting or overloading exported variables
    but it can lead to some side effects. Be aware of alphabetical order
    and keep in mind that exported variables are set. Then macros and
    groups are computed.

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

   # Use a boolean macro in a rule
   ^/admin -> $isAdmin
   # Use a string macro in a HTTP header
   Display-Name -> $displayName

Defining a group for admins

.. code-block:: perl

   # group
   admin -> $uid eq 'foo' or $uid eq 'bar'

Using groups in a rule

.. code-block:: perl

   ^/admin -> $groups =~ /\badmin\b/

   # Or with hGroups
   ^/admin -> defined $hGroups->{'admin'}

   # Since 2.0.8
   ^/admin -> inGroup('admin')


.. note::

    Groups are computed after macros, so a group rule may involve a
    macro value.


.. warning::

    Macros and groups are computed in alphanumeric order,
    that is, in the order they are displayed in the manager. For example,
    macro "macro1" will be computed before macro "macro2": so, expression of
    macro2 may involve value of macro1. As same for groups: a group rule may
    involve another, previously computed group.

.. |Exported variables in the Manager| image:: /documentation/manager-exported-variables.png
   :class: align-center

