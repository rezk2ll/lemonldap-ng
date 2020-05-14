Additional Second Factors
=========================

Starting with version 2.0.6, LemonLDAP::NG lets you configure multiple
instances of second factor authentication modules, in a manner similar
to the :doc:`Combination module<authcombination>`.

Only the following Second Factor modules are compatible with this
feature:

-  :doc:`E-Mail<mail2f>`
-  :doc:`External<external2f>`
-  :doc:`REST<rest2f>`

Using this option, lets you give your users a wider range of possible
second factors. They could decide between using their work email or home
email. And as an administrator you may now plug in more than one Second
Factor solution through :doc:`REST<rest2f>` or
:doc:`external commands<external2f>`.

Configuration
-------------

You can find the configuration for this feature in
``General parameters`` » ``Second factors`` »
``Additional second factors``

-  ``Name``: the technical name of this second factor, it should be all
   lowercase, and it is used as a sort key when second factors are
   displayed to the user
-  ``Type``: what type of second factor you want to use
-  ``Label``: what title to display in the 2F choice screen
-  ``Logo`` : URL path of a logo to display in the 2F choice screen
-  ``Level``: authentication level that will be set if this 2F is used
-  ``Rule``: If you leave this field empty, this second factor will
   always be enabled. You may use a perl expression to decide when this
   second factor is available.

   -  ``$homeMail`` : this second factor will only trigger if the
      ``$homeMail`` session key exists
   -  ``defined $hGroups{'admin'}`` : this second factor will only
      trigger if the user is in the ``admin`` group

After adding your second factors, don't forget to add overload
parameters to them. You usually should at least give them different
logos so that the user can tell the difference between two second
factors of the same type.

See the :doc:`parameters list<parameterlist>` page for a full list of
parameters you may overload. Here are the most useful ones:

-  E-Mail

::

       * ''mail2fLogo''
       * ''mailSessionKey''
       * ''mail2fCodeRegex''
       * ''mail2fSubject''
       * ''mail2fBody''
   * External
       * ''ext2fLogo''
       * ''ext2fCodeActivation''
       * ''ext2FSendCommand''
       * ''ext2FValidateCommand''
   * REST
       * ''rest2fLogo''
       * ''rest2fVerifyUrl''
       * ''rest2fVerifyArgs'' (must be a JSON object)
       * ''rest2fInitUrl''
       * ''rest2fInitArgs'' (must be a JSON object)

