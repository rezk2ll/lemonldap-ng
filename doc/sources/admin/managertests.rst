Ignore some manager tests
=========================

Each time you save a configuration, Manager launch a lot of tests:

-  unit tests for each key: they are declared in
   Lemonldap::NG::Manager::Attributes *(source
   Lemonldap::NG::Manager::Build::Attributes)* 
-  more advanced tests declared in Lemonldap::NG::Manager::Conf::Tests

In some case *(conf overridden in INI file,...)*, you may have to ignore
some of them. You just have to list them *(space separated)* in a
special key in ``lemonldap-ng.ini``, section ``[Manager]``:

-  ``skippedUnitTests`` for unit tests
-  ``skippedGlobalTests`` for global tests

Example:

.. code-block:: ini

   [Manager]
   skippedUnitTests   = grantSessionRules portalSkinRules
   skippedGlobalTests = testApacheSession

