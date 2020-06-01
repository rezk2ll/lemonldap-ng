Amazon Web Services
===================

`Amazon Web Services <https://aws.amazon.com>`__ allows one to delegate
authentication through SAML2.

SAML
----

-  Make sure you have followed the steps
   `here <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-saml.html>`__.
-  Go to https://your.portal.com/saml/metadata and save the resulting
   file locally.
-  In each AWS account, go to IAM -> Identity providers -> Create
   Provider.
-  Select ``SAML`` as the provider type
-  Choose a name (best if kept consistent between accounts), and then
   choose the metadata file you saved above.
-  Looking again at the links on the left side of the page, go to Roles
   -> Create role
-  Choose ``SAML / Saml 2.0 federation``
-  Select the provider you just configured, click
   ``Allow programmatic and AWSManagement Console access`` which will
   fill in the rest of the form for you, then click next.
-  Set whatever permissions you need to and then click ``Review``.
-  Choose a name for the role. These will shown to people when they log
   in, so make them descriptive. We have different accounts for
   different regions of the world, so I put the region into the role
   name so people know which account is which.


.. attention::

    If you have only one role, the configuration is simple. If you
    have multiple roles for different people, it is a little trickier. As
    you will see, the SAML attributes are not dynamic, so you have to set
    them in the session when a user logs in or use a custom function. In
    this example, I wanted to avoid managing custom functions on all the
    servers, so the SAML attributes are set in the session. We also use LDAP
    for user information, so I will describe that. In our LDAP tree, each
    user has attributes which are used quite heavily for dynamic groups and
    authorisation. You will want something similar, using whatever attribute
    makes sense to you. For example:

    .. code::

         dn: uid=user,ou=people,dc=your,dc=com
         ...
         ou: sysadmin
         ou: database
         ou: root



-  Assuming you use the web interface to manage lemonldap, go to General
   Parameters -> Authentication parameters -> LDAP parameters ->
   Exported variables. Here set the key to the LDAP attribute and the
   value to something sensible. I keep them the same to make it easy.
-  Now go to \*Variables -> Macros*. Here set up variables which will be
   computed based on the attributes you exported above. You will need to
   emit strings in this format
   ``arn:aws:iam::account-number:role/role-name1,arn:aws:iam::account-number:saml-provider/provider-name``.
   The parts you need to change are ``account-number``, ``role-name1``
   and ``provier-name``. The last two will be the provider name and role
   names you just set up in AWS.
-  Perl works in here, so something like this is valid: ``aws_eu_role``
   -> ``$ou =~ sysadmin ? "arn:aws..." : "arn:..."``
-  If it easier, split multiple roles into different macros. Then tie
   all the variables you define together into one string concatenating
   them with whatever is in General Parameters -> Advanced Parameters ->
   Separator. Actually click into this field and move around with the
   arrow keys to see if there is a space, since spaces can be part of
   the separator.
-  Remember macros are defined alphanumerically, so you want one right
   at the end, like ``z_aws_roles`` ->
   ``join("; ", $role_name1, $role_name2, ...)``
-  On the left again, click ``SAML service providers``, then
   ``Add SAML SP``.
-  Enter a name, click ok, then select it on the left. Select
   ``Metadata``, then enter
   \`\ https://signin.aws.amazon.com/static/saml-metadata.xml\ \` in the
   ``URL`` field, then click load.
-  Click ``Exported attributes`` on the left, then ``Add attribute``
   twice to add two attributes. The first field is the name of a
   variable set in the user's session:

   -  ``_whatToTrace`` ->
      ``https://aws.amazon.com/SAML/Attributes/RoleSessionName`` (leave
      the rest)
   -  ``z_aws_roles`` (the macro name you defined above) ->
      ``https://aws.amazon.com/SAML/Attributes/Role`` (leave the rest)

-  On the left, select Options -> Security -> Enable use of IDP
   initiated URL -> On
-  Select General Parameters -> Portal -> Menu -> Categories and
   applications
-  Select a category or create a new one if you need to. Then click
   ``New application``.
-  Enter a name etc. For the URL, use
   ``https://your.portal.com/saml/singleSignOn?IDPInitiated=1&sp=urn:amazon:webservices``
-  Display application should be set to ``Enabled``
-  Go to your portal, click on the link, and check that it works!
