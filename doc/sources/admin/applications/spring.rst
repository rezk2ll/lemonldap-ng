Spring Security (ACEGI)
=======================

|image0|

Presentation
------------

`Spring
Security <http://static.springsource.org/spring-security/site/>`__ is
the new ACEGI name. This is a well known security framework for J2EE
applications.

Spring Security provides a default ``pre-authentication`` mechanism that
can be used to connect your J2EE application to LL::NG.

Configuration
-------------

You can find all suitable information here:
http://static.springsource.org/spring-security/site/docs/3.0.x/reference/preauth.html

To summarize, to get the user connected through the ``Auth-User`` HTTP
Header, use this Sping Security configuration:

.. code-block:: xml

   <bean id="LemonLDAPNGFilter" class=
   "org.springframework.security.web.authentication.preauth.header.RequestHeaderPreAuthenticatedProcessingFilter">
       <security:custom-filter position="PRE_AUTH_FILTER" />
       <property name="principalRequestHeader" value="Auth-User"/>
       <property name="authenticationManager" ref="authenticationManager" />
   </bean>

   <bean id="preauthAuthProvider" class="org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationProvider">
     <security:custom-authentication-provider />
       <property name="preAuthenticatedUserDetailsService">
       <bean id="userDetailsServiceWrapper" class="org.springframework.security.userdetails.UserDetailsByNameServiceWrapper">
         <property name="userDetailsService" ref="userDetailsService"/>
       </bean>
     </property>
   </bean>

   <security:authentication-manager alias="authenticationManager" />

.. |image0| image:: /applications/spring_logo.png
   :class: align-center

