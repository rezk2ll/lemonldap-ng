Alfresco
========

|image0|

Presentation
------------

`Alfresco <https://www.alfresco.com/>`__ is an ECM/BPM software.

Since 4.0 release, it offers an easy way to configure SSO thanks to
authentication subsystems.

Authentication against LL::NG can be done through:

-  HTTP headers (LL::NG Handler)
-  SAML 2 (LL::NG as SAML2 IDP)


.. tip::

    Alfresco now recommends SAML2 method

HTTP headers
------------

.. _alfresco-1:

Alfresco
~~~~~~~~


.. tip::

    The official documentation can be found here:
    http://docs.alfresco.com/4.0/tasks/auth-alfrescoexternal-sso.html\

You need to find the following files in your Alfresco installation:

-  ``alfresco-global.properties`` (ex:
   ``tomcat/shared/classes/alfresco-global.properties``)
-  ``share-config-custom.xml`` (ex:
   ``tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml``)

The first will allow one to configure SSO for the alfresco webapp, and
the other for the share webapp.

Edit first ``alfresco-global.properties`` and add the following:

.. code-block:: properties

   ### SSO ###
   authentication.chain=external1:external
   external.authentication.enabled=true
   external.authentication.defaultAdministratorUserNames=
   external.authentication.proxyUserName=
   external.authentication.proxyHeader=Auth-User
   external.authentication.userIdPattern=

Edit then ``share-config-custom.xml`` and uncomment the last part. In
the ``<endpoint>``, change ``<connector-id>`` value to
``alfrescoHeader`` and change the ``<userHeader>`` value to
``Auth-User``:

.. code-block:: xml

      <config evaluator="string-compare" condition="Remote">
         <remote>
             <keystore>
                <path>alfresco/web-extension/alfresco-system.p12</path>
                <type>pkcs12</type>
                <password>alfresco-system</password>
            </keystore>

            <connector>
               <id>alfrescoCookie</id>
               <name>Alfresco Connector</name>
               <description>Connects to an Alfresco instance using cookie-based authentication</description>
               <class>org.alfresco.web.site.servlet.SlingshotAlfrescoConnector</class>
            </connector>

            <connector>
               <id>alfrescoHeader</id>
               <name>Alfresco Connector</name>
               <description>Connects to an Alfresco instance using header and cookie-based authentication</description>
               <class>org.alfresco.web.site.servlet.SlingshotAlfrescoConnector</class>
               <userHeader>Auth-User</userHeader>
            </connector>

            <endpoint>
               <id>alfresco</id>
               <name>Alfresco - user access</name>
               <description>Access to Alfresco Repository WebScripts that require user authentication</description>
               <connector-id>alfrescoHeader</connector-id>
               <endpoint-url>http://localhost:8080/alfresco/s</endpoint-url>
               <identity>user</identity>
               <external-auth>true</external-auth>
            </endpoint>
         </remote>
      </config>

You need to restart Tomcat to apply changes.


.. danger::

    Now you can log in with a simple HTTP header. You need to
    restrict access to Alfresco to LL::NG.

LL::NG
~~~~~~

Headers
^^^^^^^

Just set the ``Auth-User`` header with the attribute that carries the
user login, for example ``$uid``.

Rules
^^^^^

Set the default rule to what you need.

Other rules:

-  Unprotect access to some resources: ``^/share/res => unprotect``
-  Catch logout: ``^/share/page/dologout => logout_app_sso``

SAML2
-----

.. _alfresco-2:

Alfresco
~~~~~~~~

Install SAML Alfresco module package:

::

   cp alfresco-saml-repo-1.0.1.amp <ALFRESCO_HOME>/amps
   cp alfresco-saml-share-1.0.1.amp <ALFRESCO_HOME>/amps_share
   ./bin/apply_amp.sh

Generate SAML certificate:

::

   keytool -genkeypair -alias my-saml-key -keypass change-me -storepass change-me -keystore my-saml.keystore -storetype JCEKS

Export the keystore:

::

   mv my-saml.keystore alf_data/keystore
   cat <<EOT > alf_data/keystore/my-saml.keystore-metadata.properties
   aliases=my-saml-key
   keystore.password=change-me
   my-saml-key.password=change-me
   EOT
   cat <<EOT >> tomcat/shared/classes/alfresco-global.properties

   saml.keystore.location=\${dir.keystore}/my-saml.keystore
   saml.keystore.keyMetaData.location=\${dir.keystore}/my-saml.keystore-metadata.properties
   EOT

Edit then ``share-config-custom.xml``:

.. code-block:: xml

       ...
           <config evaluator="string-compare" condition="CSRFPolicy" replace="true">



           <!--
               If using https make a CSRFPolicy with replace="true" and override the properties section.
               Note, localhost is there to allow local checks to succeed.



               I.e.
               <properties>
                   <token>Alfresco-CSRFToken</token>
                   <referer>https://your-domain.com/.*|http://localhost:8080/.*</referer>
                   <origin>https://your-domain.com|http://localhost:8080</origin>
               </properties>
           -->



               <filter>



                   <!-- SAML SPECIFIC CONFIG -  START -->



                   <!--
                    Since we have added the CSRF filter with filter-mapping of "/*" we will catch all public GET to avoid them
                    having to pass through the remaining rules.
                    -->
                   <rule>
                       <request>
                           <method>GET</method>
                           <path>/res/.*</path>
                       </request>
                   </rule>



                   <!-- Incoming posts from IDPs do not require a token -->
                   <rule>
                       <request>
                           <method>POST</method>
                           <path>/page/saml-authnresponse|/page/saml-logoutresponse|/page/saml-logoutrequest</path>
                       </request>
                   </rule>



                   <!-- SAML SPECIFIC CONFIG -  STOP -->



                   <!-- EVERYTHING BELOW FROM HERE IS COPIED FROM share-security-config.xml -->



                   <!--
                    Certain webscripts shall not be allowed to be accessed directly form the browser.
                    Make sure to throw an error if they are used.
                    -->
                   <rule>
                       <request>
                           <path>/proxy/alfresco/remoteadm/.*</path>
                       </request>
                       <action name="throwError">
                           <param name="message">It is not allowed to access this url from your browser</param>
                       </action>
                   </rule>



                   <!--
                    Certain Repo webscripts should be allowed to pass without a token since they have no Share knowledge.
                    TODO: Refactor the publishing code so that form that is posted to this URL is a Share webscript with the right tokens.
                    -->
                   <rule>
                       <request>
                           <method>POST</method>
                           <path>/proxy/alfresco/api/publishing/channels/.+</path>
                       </request>
                       <action name="assertReferer">
                           <param name="referer">{referer}</param>
                       </action>
                       <action name="assertOrigin">
                           <param name="origin">{origin}</param>
                       </action>
                   </rule>



                   <!--
                    Certain Surf POST requests from the WebScript console must be allowed to pass without a token since
                    the Surf WebScript console code can't be dependent on a Share specific filter.
                    -->
                   <rule>
                       <request>
                           <method>POST</method>
                           <path>/page/caches/dependency/clear|/page/index|/page/surfBugStatus|/page/modules/deploy|/page/modules/module|/page/api/javascript/debugger|/page/console</path>
                       </request>
                       <action name="assertReferer">
                           <param name="referer">{referer}</param>
                       </action>
                       <action name="assertOrigin">
                           <param name="origin">{origin}</param>
                       </action>
                   </rule>



                   <!-- Certain Share POST requests does NOT require a token -->
                   <rule>
                       <request>
                           <method>POST</method>
                           <path>/page/dologin(\?.+)?|/page/site/[^/]+/start-workflow|/page/start-workflow|/page/context/[^/]+/start-workflow</path>
                       </request>
                       <action name="assertReferer">
                           <param name="referer">{referer}</param>
                       </action>
                       <action name="assertOrigin">
                           <param name="origin">{origin}</param>
                       </action>
                   </rule>



                   <!-- Assert logout is done from a valid domain, if so clear the token when logging out -->
                   <rule>
                       <request>
                           <method>POST</method>
                           <path>/page/dologout(\?.+)?</path>
                       </request>
                       <action name="assertReferer">
                           <param name="referer">{referer}</param>
                       </action>
                       <action name="assertOrigin">
                           <param name="origin">{origin}</param>
                       </action>
                       <action name="clearToken">
                           <param name="session">{token}</param>
                           <param name="cookie">{token}</param>
                       </action>
                   </rule>



                   <!-- Make sure the first token is generated -->
                   <rule>
                       <request>
                           <session>
                               <attribute name="_alf_USER_ID">.+</attribute>
                               <attribute name="{token}"/>
                               <!-- empty attribute element indicates null, meaning the token has not yet been set -->
                           </session>
                       </request>
                       <action name="generateToken">
                           <param name="session">{token}</param>
                           <param name="cookie">{token}</param>
                       </action>
                   </rule>



                   <!-- Refresh token on new "page" visit when a user is logged in -->
                   <rule>
                       <request>
                           <method>GET</method>
                           <path>/page/.*</path>
                           <session>
                               <attribute name="_alf_USER_ID">.+</attribute>
                               <attribute name="{token}">.+</attribute>
                           </session>
                       </request>
                       <action name="generateToken">
                           <param name="session">{token}</param>
                           <param name="cookie">{token}</param>
                       </action>
                   </rule>



                   <!--
                    Verify multipart requests from logged in users contain the token as a parameter
                    and also correct referer & origin header if available
                    -->
                   <rule>
                       <request>
                           <method>POST</method>
                           <header name="Content-Type">multipart/.+</header>
                           <session>
                               <attribute name="_alf_USER_ID">.+</attribute>
                           </session>
                       </request>
                       <action name="assertToken">
                           <param name="session">{token}</param>
                           <param name="parameter">{token}</param>
                       </action>
                       <action name="assertReferer">
                           <param name="referer">{referer}</param>
                       </action>
                       <action name="assertOrigin">
                           <param name="origin">{origin}</param>
                       </action>
                   </rule>



                   <!--
                    Verify that all remaining state changing requests from logged in users' requests contains a token in the
                    header and correct referer & origin headers if available. We "catch" all content types since just setting it to
                    "application/json.*" since a webscript that doesn't require a json request body otherwise would be
                    successfully executed using i.e."text/plain".
                    -->
                   <rule>
                       <request>
                           <method>POST|PUT|DELETE</method>
                           <session>
                               <attribute name="_alf_USER_ID">.+</attribute>
                           </session>
                       </request>
                       <action name="assertToken">
                           <param name="session">{token}</param>
                           <param name="header">{token}</param>
                       </action>
                       <action name="assertReferer">
                           <param name="referer">{referer}</param>
                       </action>
                       <action name="assertOrigin">
                           <param name="origin">{origin}</param>
                       </action>
                   </rule>
               </filter>
           </config>
       ...

Configure SAML service provider using the Alfresco admin console
(/alfresco/s/enterprise/admin/admin-saml).

Set the following parameters:

-  Enable SAML Authentication (SSO): on
-  Authentication service URL:
   https://auth.example.com/saml/singleSignOn
-  Single Logout URL: https://auth.example.com/saml/singleLogout
-  Single logout return URL:
   https://auth.example.com/saml/singleLogoutReturn
-  Entity identification: http://alfresco.myecm.org:8080/share
-  User ID mapping: Subject/NameID

To finish with Alfresco configuration, tick the “Enable SAML
authentication (SSO)” box.

.. _llng-1:

LL::NG
~~~~~~

Configure SAML service and set a certificate as signature public key in
metadata.

Export Alfresco SAML Metadata from admin console and import them in
LL::NG.

In the authentication response option, set:

-  Default NameID Format: Unspecified
-  Force NameID session key: uid

And you can define these exported attributes:

-  GivenName
-  Surname
-  Email

Other resources
---------------

-  `DevCon 2012: Unlocking the Secrets of Alfresco Authentication, Mehdi
   Belmekki <https://www.youtube.com/watch?v=5tS0XrC_-rw>`__
-  `Setting up Alfresco SAML authentication with
   LemonLDAP::NG <https://community.alfresco.com/blogs/alfresco-premier-services/2017/08/03/setting-up-alfresco-saml-authentication-lemonldapng>`__

.. |image0| image:: /applications/alfresco_logo.png
   :class: align-center

