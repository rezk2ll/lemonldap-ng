Apache Tomcat
=============

|image0|


.. attention::

    The Tomcat Valve is only available for tomcat 5.5 or
    greater.

Presentation
------------

`Apache Tomcat <http://tomcat.apache.org/>`__ is an open source software
implementation of the Java Servlet and JavaServer Pages technologies.

As J2EE servlet container, Tomcat provides standard security feature,
like authentication: the application deployed in Tomcat can delegate its
authentication to Tomcat.

By default, Tomcat provides a file called ``users.xml`` to manage
authentication:

.. code-block:: xml

   <?xml version='1.0' encoding='utf-8'?>
   <tomcat-users>
     <role rolename="tomcat"/>
     <role rolename="role1"/>
     <user username="tomcat" password="tomcat" roles="tomcat"/>
     <user username="role1" password="tomcat" roles="role1"/>
     <user username="both" password="tomcat" roles="tomcat,role1"/>
   </tomcat-users>


LL::NG provides a valve that will check an HTTP header to set the authenticated user on
the J2EE container.

Compilation
-----------

The sources are available at `<https://github.com/LemonLDAPNG/lemonldap-valve-tomcat>`__

Required :

-  ant
-  jre > 1.4
-  tomcat >= 5.5

Configure your tomcat home in ``build.properties`` files.


.. attention::

    Be careful for Windows user, path must contains "/".
    Example:

    ::

       c:/my hardisk/tomcat/



Next run ant command:

::

   ant

``ValveLemonLDAPNG.jar`` is created under ``/dist`` directory.

.. |image0| image:: /applications/tomcat_logo.png
   :class: align-center


Installation
------------

Copy ``ValveLemonLDAPNG.jar`` in ``<TOMCAT_HOME>/server/lib``:

::

   cp ValveLemonLDAPNG.jar server/lib/


.. tip::

    If needed, you can
    :doc:`recompile the valve from the sources<>`.

Configuration
-------------

Add on your ``server.xml`` file a new valve entry like this (in host
section):

.. code-block:: xml

   <Valve className="org.lemonLDAPNG.SSOValve" userKey="AUTH-USER" roleKey="AUTH-ROLE" roleSeparator="," allows="127.0.0.1"/>

Configure attributes:

-  **userKey**: key in the HTTP header containing user login.
-  **roleKey**: key in the HTTP header containing roles. If LL::NG send
   some roles split by some commas, configure **roleSeparator**.
-  **roleSeparator** (optional): role values separator.
-  **allows** (optional): Define allowed remote IP (use "," separator
   for multiple IP). Just set the LL::NG Handler IP on this attribute in
   order to add more security. If this attribute is missed all hosts are
   allowed.
-  **passThrough** (optional): Allow anonymous access or not. When it
   takes "false", HTTP headers have to be sent by LL::NG to make
   authentication. So, if the user is not recognized or HTTP headers not
   present, a 403 error is sent.


.. tip::

    For debugging, this valve can print some helpful information
    in debug level. See `how configure logging in
    Tomcat <http://tomcat.apache.org/tomcat-5.5-doc/logging.html>`__ .

