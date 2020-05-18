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

Extend variables using macros and groups
----------------------------------------

:ref:`macros_and_groups`

.. |Exported variables in the Manager| image:: /documentation/manager-exported-variables.png
   :class: align-center

