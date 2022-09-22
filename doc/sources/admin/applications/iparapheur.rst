i-Parapheur
===========

|image0|

Presentation
------------

`i-Parapheur <https://www.libriciel.fr/i-parapheur/>`__ is a web application
allowing digital signature on documents. It was built around Alfresco.

It can use external authentication based on HTTP header.

Configuration
-------------

On i-Parapheur
~~~~~~~~~~~~~~

Edit ``/opt/iParapheur/tomcat/shared/classes/alfresco-global.properties`` and add:

.. code-block:: ini

   parapheur.auth.external.header.authorize=true

Edit ``/opt/iParapheur/tomcat/shared/classes/iparapheur-global.properties`` and add:

.. code-block:: ini

   parapheur.auth.external.header.name=Auth-User
   parapheur.auth.external.header.regexp=.*

On LemonLDAP::NG
~~~~~~~~~~~~~~~~

Go to the Manager and :doc:`create a new virtual host<../configvhost>` for iParapheur.

Just configure the :ref:`access rules<rules>`.

Create the ``Auth-User`` :ref:`header<headers>` to send the user login to iParapheur.


.. |image0| image:: /applications/iparapheur_logo.png
   :class: align-center

