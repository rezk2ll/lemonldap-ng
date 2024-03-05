Overlay configuration backend
=============================

This configuration backend permits one to store part of the configuration in
local files. For example you can use this to store secrets outside LLNG
configuration.

lemonldap-ng.ini example:

.. code-block:: ini

   [configuration]
   type = Overlay
   overlayRealtype = File
   overlayDirectory = /var/lib/lemonldap-ng/secrets

   # File parameters
   dirName = /var/lib/lemonldap-ng/conf

Then store in the **overlayDirectory** a file for each parameter *(filename == keyname)*

Parameters
~~~~~~~~~~

* **overlayRealtype** *(required)*: the real configuration backend
* **overlayDirectory** *(required)*: the directory where overriden parameters
  are stored
* **overlayWrite** *(optional)*: set to 1 if you want that configuration
  changes are applied to overlay, else overlay parameters are read-only
