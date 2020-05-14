REST/SOAP servers
=================

Presentation
------------

LL::NG portal can be configured as REST or *(deprecated)* SOAP server,
for several usage:

-  Configuration access
-  Sessions access
-  Authentication
-  Specific application needs

Configuration
-------------

REST
~~~~

Go in ``General Parameters`` > ``Plugins`` > ``Portal servers``:

-  **REST session server**: Enable REST for sessions
-  **REST configuration server**: Enable REST for configuration
-  **SOAP/REST exported attributes**: list session attributes shared
   trough REST

   -  use ``+`` to append to the default list of technical attributes,
      example: ``+ uid mail``

See also :doc:`REST Services<restservices>`.

SOAP *(deprecated)*
~~~~~~~~~~~~~~~~~~~

Go in ``General Parameters`` > ``Plugins`` > ``Portal servers``:

-  **SOAP session server**: Enable SOAP for sessions
-  **SOAP configuration server**: Enable SOAP for configuration
-  **SOAP/REST exported attributes**: list session attributes shared
   trough SOAP

   -  use ``+`` to append to the default list of technical attributes,
      example: ``+ uid mail``

See also :doc:`SOAP Services<soapservices>`.
