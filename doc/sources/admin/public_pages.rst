Public pages
============

Presentation
------------

Public pages are an easy way to build pages based on LL::NG portal skin.
You can for example create a page for a legal notice or usage instructions.

A public page is just a template created in the ``public/`` subdirectory of the skin, for example ``test.tpl``.

This page can then be displayed with this URL:
http://auth.example.com/public/test

Plugin activation
-----------------

You need to enable this plugin as a custom plugin.

Add ``::Plugins::PublicPages`` to the custom plugins list in your configuration.

Page creation
-------------

Create the new page:

::

   vi /var/lib/lemonldap-ng/portal/skins/bootstrap/public/legal.tpl

.. code-block:: html

   <TMPL_INCLUDE NAME="header.tpl">

   <div class="container">
     <div class="alert alert-success">
       Important legal notice
     </div>
   </div>

   <TMPL_INCLUDE NAME="footer.tpl">

Display the page: http://auth.example.com/public/legal

.. tip::

   If you use a custom skin, you need to create the ``public/`` directory in the skin templates directory.

.. warning::

   A default test page is provided (``test.tpl``), you can use it as an example and delete it if you don't need it.

