Public pages
============


.. note::

    Public pages are available since version 1.9.8.

Presentation
------------

Public pages are an easy way to build pages based on LL::NG portal skin.
You can for example create a landing page or customize error pages with
it.

A public page is just a template created in
portal/skins\ */yourskin*/public/ directory, for example test.tpl. This
page can then be displayed with this URL:
http://auth.example.com/public?page=test

Page creation
-------------

Create the public/ directory :

::

   mkdir /var/lib/lemonldap-ng/portal/skins/bootstrap/public

Create the new page:

::

   vi /var/lib/lemonldap-ng/portal/skins/bootstrap/public/test.tpl

.. code-block:: html

   <TMPL_INCLUDE NAME="../header.tpl">

   <div class="container">
     <div class="alert alert-success">
       TEST
     </div>
   </div>

   <TMPL_INCLUDE NAME="../footer.tpl">

Display the page: http://auth.example.com/public?page=test
