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

-  **REST/SOAP exported attributes**: list session attributes shared
   through SOAP/REST
   
   -  Use ``+`` to append the default list of technical attributes,
      example: ``+ uid mail``

REST
~~~~

Go in ``General Parameters`` > ``Plugins`` > ``Portal servers`` > ``REST services``:

-  **Session server**: Enable REST for sessions
-  **Configuration server**: Enable REST for configuration
-  **Authentication server**: Enable REST for authentication
-  **Password reset server**: Enable REST for password reset
-  **Server clock tolerance**: Allow a clock drift
-  **Export secret attributes**: Secret attributes can be exported

See also :doc:`REST Services<restservices>`.

SOAP *(deprecated)*
~~~~~~~~~~~~~~~~~~~

Go in ``General Parameters`` > ``Plugins`` > ``Portal servers`` > ``SOAP services``:

-  **Session server**: Enable SOAP for sessions
-  **Configuration server**: Enable SOAP for configuration
-  **WSDL server**: Enable WSDL server

See also :doc:`SOAP Services<soapservices>`.
