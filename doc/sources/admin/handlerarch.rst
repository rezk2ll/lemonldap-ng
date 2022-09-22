Handler libraries architecture
==============================

Handlers are build on rows of modules:

-  Applications or launchers that get the request and choose the right
   type *(Main, AuthBasic, ZimbraPreAuth,...)* and launch it *(may not
   inherits from other Handler::\* modules)*
-  Wrappers that call "type" library and platform "Main" (may all
   inherits from Platform::Main
-  Library types if needed *(may inherit from Main)*
-  Main: the main handler library

Overview of Handler packages
----------------------------

============================================================================== ============  ================= =========== ====
Usage                                                                          Platform      Wrapper           Types       Main
============================================================================== ============  ================= =========== ====
Apache2 protection                                                             ApacheMP2     ApacheMP2::<type> Lib::<type> Main
Plack servers protection or Nginx/\ :doc:`SSOaaS<ssoaas>` FastCGI/uWSGI server Server        Server::<type>
:doc:`Self protected applications<selfmadeapplication>`                        PSGI          PSGI::<type>
============================================================================== ============  ================= =========== ====

Types are:

-  *(Main)*: link between Main and platform
-  :doc:`AuthBasic<authbasichandler>`
-  :doc:`CDA<cda>`
-  :doc:`DevOps<devopshandler>`
-  :doc:`DevOps+ServiceToken<devopssthandler>`
-  :doc:`OAuth2<oauth2handler>`
-  :doc:`SecureToken<securetoken>` *(not available for PSGI)*
-  :doc:`Service Token<servertoserver>` *(server to server)*
-  :doc:`ZimbraPreAuth<applications/zimbra>` *(not
   available for PSGI)*
