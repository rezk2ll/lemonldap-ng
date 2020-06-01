SOAP services (deprecated)
==========================

LL::NG portal provide a SOAP server that can be enable to give
configuration and/or session. These features can be enabled using the
manager.

Portal SOAP services
--------------------

SOAP functions are not accessible by network by default. SOAP functions
are protected by Web Server, you can change this in
:ref:`portal configuration<configlocation-portal>`.

-  Read-only functions (index.pl/sessions or index.pl/adminSessions
   paths):

   -  **getCookies(user,password)**: authentication system. Returns
      cookie(s) name and values
   -  **getAttributes(cookieValue)**: get elements stored in session
   -  **isAuthorizedURI(cookieValue,url)**: check if user is granted to
      access to the function
   -  **getMenuApplications(cookieValue)**: return a list of
      authorizated applications (based on menu calculation)

-  Read/Write functions (index.pl/adminSessions paths):

   -  **setAttributes(cookieValue,hashtable)**: update a session
   -  **newSession**: create a session (return attributes)
   -  **deleteSession**: delete a session
   -  **get_key_from_all_sessions**: list all sessions and return asked
      keys

-  Notification send function (index.pl/notification):

   -  **newNotification(xmlString)**: insert a notification for a user
      (see :doc:`Notifications system<notifications>` for more)

-  Notification delete function:

   -  **deleteNotification**: delete notification(s) for a user (see
      :doc:`Notifications system<notifications>` for more)


.. attention::

    When you use
    :doc:`SOAP sessions backend<soapsessionbackend>`, it is recommended to
    use read-only URL (/index.fcgi/sessions). Write session path is needed
    only if you use a remote session explorer or a remote portal

WSDL
----

You can enable WSDL server in the manager. It will deliver WSDL file
(/portal.wsdl).
