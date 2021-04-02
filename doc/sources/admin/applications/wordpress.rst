Wordpress
=========

|image0|

Presentation
------------

`Wordpress <https://wordpress.org/>`__ is a famous tool to create
websites.

A lot of authentication plugins are available. We propose here to use
CAS protocol and `WP
Cassify <https://wordpress.org/plugins/wp-cassify/>`__ plugin.

CAS
---

Plugin installation
~~~~~~~~~~~~~~~~~~~

Go in Wordpress admin and install `WP
Cassify <https://wordpress.org/plugins/wp-cassify/>`__ plugin.

Plugin configuration
~~~~~~~~~~~~~~~~~~~~

The full documentation is available on https://wpcassify.wordpress.com/

General settings
^^^^^^^^^^^^^^^^

Configure CAS server and CAS version:

-  CAS Server base url : https://auth.example.com/cas/
-  CAS Version protocol: 2

Other options are correct by default.

User Roles Settings
^^^^^^^^^^^^^^^^^^^

You can assign WP Roles depending on values sent by CAS.

The rules syntax is quite special, you can use it or you can just define
macros on LL::NG side and send them through CAS to keep simple rules on
WP side.

For example create a macro ``role_wordpress_admin`` which contains ``1``
if the user is admin on WP, and send it in CAS attributes.

Then create this rule on WP side:

::

   administrator|(CAS{role_wordpress_admin} -EQ "1")

.. |image0| image:: /applications/wordpress_logo.png
   :class: align-center

