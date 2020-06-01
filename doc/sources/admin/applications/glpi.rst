GLPI
====

|image0|

Presentation
------------

`GLPI <http://www.glpi-project.org>`__ is the Information
Resource-Manager with an additional Administration- Interface. You can
use it to build up a database with an inventory for your company
(computer, software, printers...). It has enhanced functions to make the
daily life for the administrators easier, like a job-tracking-system
with mail-notification and methods to build a database with basic
information about your network-topology.

Configuration
-------------

For GLPI >= 0.71, it is a simple configuration in GLPI: Setup →
Authentication. In “External authentications” click “Others” and in
“Field holding the login in the \_SERVER array” select “REMOTE_USER”

For older version, check
http://wiki.glpi-project.org/doku.php?id=en:authautoad

If you use Nginx, you need to add this in configuration:

.. code-block:: nginx

   proxy_set_header Host $http_host;
   proxy_set_header X-Forwarded-Host $http_host;
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

.. |image0| image:: /applications/glpi_logo.png
   :class: align-center

