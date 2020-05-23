Monitoring
==========

.. toctree::
   :hidden:

   mrtg

Handler can be monitored by using MRTG. See
:doc:`MRTG monitoring<mrtg>`.

Portal can also publish its status using REST. To enable it, go to the
manager, general parameters, plugins. Then enable "publish portal
status" option.

Then protect http://auth.yourdomain/portalStatus in webserver
configuration.

This REST URL just publishes a hash containing number of sessions of
each type.
