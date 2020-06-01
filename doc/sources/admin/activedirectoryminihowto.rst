Using LemonLDAP::NG with Active-Directory
=========================================

Authentication with login/password
----------------------------------

To use Active Directory as LDAP backend, you must change few things in
the manager :

-  Use "Active Directory" as authentication, userDB and
   passwordDBbackends,
-  Export sAMAccountName in a variable declared in
   :doc:`exported variables<exportedvars>`
-  Change the user attribute to store in Apache logs *("General
   Parameters » Logs » REMOTE_USER")*: use the variable declared above

Authentication with Kerberos
----------------------------

-  Choose "Apache" as authentication module *("General Parameters »
   Authentication modules » Authentication module")*
-  :doc:`Configure the Apache server<authapache>` that host the portal
   to use the Apache Kerberos authentication module
