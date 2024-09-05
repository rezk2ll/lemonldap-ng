Template updates
================

.. note:: 

    The content of this page only applies to you if:

    * You are using a custom LemonLDAP::NG theme
    * AND you modified some of LemonLDAP::NG's base templates (``login.tpl``,
      etc.). Note that templates whose name start with ``custom`` (``customfooter.tpl``, etc.) do NOT count.

    In other words, you can safely ignore this entire page if:

    * You only changed the logo or background
    * OR you created a custom theme and the only templates you modified are the ones that start with ``custom`` (``customfooter.tpl``, etc.)


2.20.0
------

Password policy
^^^^^^^^^^^^^^^

The requirement for new password and new password confirmation to match is now
displayed in the password policy, if you changed ``passwordpolicy.tpl``, you
need to update it:

.. code-block:: diff

    --- a/lemonldap-ng-portal/site/templates/bootstrap/passwordpolicy.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/passwordpolicy.tpl
    @@ -11,8 +11,9 @@
             </li>
             </TMPL_IF>
         </TMPL_LOOP>
    +    <li>
    +        <i id="samepassword-feedback" class="fa fa-li"> </i>
    +        <span trspan="passwordPolicySamePwd"></span>
    +    </li>
       </ul>
    -  <TMPL_IF NAME="PPOLICY_NOPOLICY">
    -    <span trspan="passwordPolicyNone">You are free to choose your password! ;-)</span>
    -  </TMPL_IF>
     </div>


WebAuthn registration and authentication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you modified the `webauthn2fcheck.tpl` or `/webauthn2fregister.tpl`, you
will start noticing harmless but confusing error messages during WebAuthn
checks or registration. In order to fix this, remove the javascript inclusions
from both templates.


.. code-block:: diff

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl b/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl
    index aad8d4886..5d4f24fad 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl
    @@ -17,13 +17,6 @@
       <script type="application/init">
       <TMPL_VAR NAME="DATA">
       </script>
    -<!-- //if:jsminified
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthn-ui.min.js"></script>
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthncheck.min.js"></script>
    -//else -->
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthn-ui.js"></script>
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthncheck.js"></script>
    -<!-- //endif -->
     </TMPL_IF>

     </div>
    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fregister.tpl b/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fregister.tpl
    index d2e9d9df9..fe1f194f7 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fregister.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fregister.tpl
    @@ -43,12 +43,4 @@
         <span trspan="goToPortal">Go to portal</span>
       </a>
     </div>
    -
    -<!-- //if:jsminified
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthn-ui.min.js"></script>
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthnregistration.min.js"></script>
    -//else -->
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthn-ui.js"></script>
    -  <script type="text/javascript" src="<TMPL_VAR NAME="STATIC_PREFIX">/common/js/webauthnregistration.js"></script>
    -<!-- //endif -->
     <TMPL_INCLUDE NAME="footer.tpl">

Passwordless WebAuthn
^^^^^^^^^^^^^^^^^^^^^

In order to support autocompletion of WebAuthn credentials on supported web browsers, update `standardlogin.tpl`

.. code:: diff

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl b/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    index c6af84745..81ce95c3d 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    @@ -10,7 +10,8 @@
         <div class="input-group-prepend">
           <span class="input-group-text"><label for="userfield" class="mb-0"><i class="fa fa-user"></i></label></span>
         </div>
    -    <input id="userfield" name="user" type="text" class="form-control" value="<TMPL_VAR NAME="LOGIN">" trplaceholder="login" required aria-required="true"/>
    +    <input id="userfield" name="user" type="text" class="form-control" value="<TMPL_VAR NAME="LOGIN">"
    +      trplaceholder="login" required aria-required="true" autocomplete="webauthn"/>
       </div>
       <div class="input-group mb-3">
         <div class="input-group-prepend">


Also update `2fregisters.tpl` to that resident credentials are properly show to the user

.. code:: diff

    --- a/lemonldap-ng-portal/site/templates/bootstrap/2fregisters.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/2fregisters.tpl
    @@ -33,6 +33,11 @@
                 <TMPL_ELSE>
                     <TMPL_VAR NAME="type">
                 </TMPL_IF>
    +            <TMPL_IF name="type_WebAuthn">
    +                <TMPL_IF name="resident">
    +                <span trattribute="title:webauthnResident" class="fa fa-key"></span>
    +                </TMPL_IF>
    +            </TMPL_IF>
                 </td>
                 <td class="align-middle"><TMPL_VAR NAME="name"></td>
                 <td class="data-epoch"><TMPL_VAR NAME="epoch"></td>

2.19.0
------

TOTP registration
^^^^^^^^^^^^^^^^^

The TOTP registration now offers a ``otpauth://`` url that can automatically open your TOTP application when viewed on mobile. Apply the following patch to ``totp2fregister.tpl`` to use this new feature::

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/totp2fregister.tpl b/lemonldap-ng-portal/site/templates/bootstrap/totp2fregister.tpl
    index 506a83481..a14e61d31 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/totp2fregister.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/totp2fregister.tpl
    @@ -11,8 +11,8 @@
             <div class="col-md-6 text-center">
               <div >
                 <p>&#x2460; <span trspan="totpQrCode"></span></p>
    -            <canvas id="qr"></canvas>
    -
    +            <p><a class="otpauth-url" href=""><canvas id="qr"></canvas></a></p>
    +            <p><span trspan="totpOrTouch"></span></p>
                 <p><span trspan="totpSecretKey"></span></p>
                 <tt id="secret"></tt>
               </div>

Second factor retry
^^^^^^^^^^^^^^^^^^^

It is recommended to apply the following patch to your custom templates so that users will have a more friendly error message when retrying their 2FA:

.. code-block:: diff

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl b/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl
    index 4f277f295..c0381fc9e 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl
    @@ -2,7 +2,11 @@

     <main id="logincontent" class="container">

    +<TMPL_IF NAME="AUTH_ERROR">
    +  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert" role="<TMPL_VAR NAME="AUTH_ERROR_ROLE">"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
    +<TMPL_ELSE>
     <div class="message message-positive alert"><span trspan="<TMPL_IF "LEGEND"><TMPL_VAR "LEGEND"><TMPL_ELSE>enterExt2fCode</TMPL_IF>"></span></div>
    +</TMPL_IF>

     <div class="card">

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/password2fcheck.tpl b/lemonldap-ng-portal/site/templates/bootstrap/password2fcheck.tpl
    index 098d91345..361365ef6 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/password2fcheck.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/password2fcheck.tpl
    @@ -2,7 +2,11 @@

     <main id="logincontent" class="container">

    +<TMPL_IF NAME="AUTH_ERROR">
    +  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert" role="<TMPL_VAR NAME="AUTH_ERROR_ROLE">"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
    +<TMPL_ELSE>
     <div class="message message-positive alert"><span trspan="enterPassword">Enter your password</span></div>
    +</TMPL_IF>

     <div class="card">

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/totp2fcheck.tpl b/lemonldap-ng-portal/site/templates/bootstrap/totp2fcheck.tpl
    index 427f78f6c..8e84497e6 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/totp2fcheck.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/totp2fcheck.tpl
    @@ -2,7 +2,11 @@

     <main id="logincontent" class="container">

    +<TMPL_IF NAME="AUTH_ERROR">
    +  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert" role="<TMPL_VAR NAME="AUTH_ERROR_ROLE">"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
    +<TMPL_ELSE>
     <div class="message message-positive alert"><span trspan="enterTotpCode"></span></div>
    +</TMPL_IF>

     <div class="card">

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl b/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl
    index 881625d5f..aad8d4886 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/webauthn2fcheck.tpl
    @@ -3,7 +3,7 @@
     <div class="container">

     <TMPL_IF NAME="AUTH_ERROR">
    -  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
    +  <div class="message message-<TMPL_VAR NAME="AUTH_ERROR_TYPE"> alert" role="<TMPL_VAR NAME="AUTH_ERROR_ROLE">"><span trmsg="<TMPL_VAR NAME="AUTH_ERROR">"></span></div>
     </TMPL_IF>
     <TMPL_IF NAME="DATA">
       <div id="color" class="message message-positive alert"><span id="msg" trspan="webAuthnRequired"></span></div>


2.18.0
------

Password policy display
^^^^^^^^^^^^^^^^^^^^^^^

It is recommended to replace your custom theme's ``passwordpolicy.tpl`` by the one that is provided in the ``bootstrap`` theme.

If you use the :doc:`Have I Been Pwned <checkhibp>` plugin, this is a required change because the modifications in 2.18 will break this particular plugin.

If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.

Email templates
^^^^^^^^^^^^^^^

To avoid email sent by LL::NG being flagged as spam, we remove inline images in HTML content. You can add them back by customising the email templates and eithier use inline images (cid) or links to external resources.

Note that we now send a plain text version of the mail attached to the HTML email.


2.17.0
------


Font Awesome application icons
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is now possible to use Font Awesome icons in the application menu.

If you modified the default ``menu.tpl`` template, you need to update it:

.. code:: diff

    --- a/lemonldap-ng-portal/site/templates/bootstrap/menu.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/menu.tpl
    @@ -146,9 +146,13 @@
                             <!-- Logo (optional) -->
                             <TMPL_IF NAME="applogo">
                               <div class="col-3">
    +                          <TMPL_IF NAME="applogo_icon">
    +                          <span class="applogo fa-3x fa fa-<TMPL_VAR NAME="applogo"> <TMPL_VAR NAME="appid">"></span>
    +                          <TMPL_ELSE>
                               <img src="<TMPL_VAR NAME="STATIC_PREFIX">common/apps/<TMPL_VAR NAME="applogo">"
                                 class="applogo <TMPL_VAR NAME="appid"> img-fluid"
                                 alt="" />
    +                          </TMPL_IF>
                               </div>
                               <div class="col-9">
                             <TMPL_ELSE>

If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.

Password policy
^^^^^^^^^^^^^^^

It is recommended to update your theme's ``passwordpolicy.tpl`` to correctly display special characters in password policies

::

    --- a/lemonldap-ng-portal/site/templates/bootstrap/passwordpolicy.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/passwordpolicy.tpl
    @@ -34,7 +34,7 @@
         <TMPL_IF NAME="PPOLICY_ALLOWEDSPECHAR">
         <li>
             <i id="ppolicy-allowedspechar-feedback" class="fa fa-li"> </i>
    -        <span trspan="passwordPolicySpecialChar">Allowed special characters:</span> <TMPL_VAR NAME="PPOLICY_ALLOWEDSPECHAR">
    +        <span trspan="passwordPolicySpecialChar">Allowed special characters:</span> <TMPL_VAR NAME="PPOLICY_ALLOWEDSPECHAR" ESCAPE="html">
         </li>
         </TMPL_IF>
         <TMPL_IF NAME="ENABLE_CHECKHIBP">

If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.


2.0.16
------

Changes in templates
^^^^^^^^^^^^^^^^^^^^

The default ``skin.min.js`` file has been updated in this release, be sure to copy ``skin.min.js`` from ``bootstrap`` into your custom theme.

Due to some internal changes in the way registrable second factors are handled, it is recommended to update your custom `2fregisters.tpl`

.. code:: diff

    @@ -32,7 +32,14 @@
                 <td class="data-epoch"><TMPL_VAR NAME="epoch"></td>
                 <td>
                   <TMPL_IF NAME="delAllowed">
    -                <span device='<TMPL_VAR NAME="type">' epoch='<TMPL_VAR NAME="epoch">' class="btn btn-danger" role="button" data-toggle="modal" data-target="#remove2fModal">
    +                <span
    +                    device='<TMPL_VAR NAME="type">'
    +                    epoch='<TMPL_VAR NAME="epoch">'
    +                    prefix='<TMPL_VAR NAME="prefix">'
    +                    class="btn btn-danger"
    +                    role="button"
    +                    data-toggle="modal"
    +                    data-target="#remove2fModal">
                       <span class="fa fa-minus-circle"></span>
                       <span trspan="unregister">Unregister</span>
                        </span>

To fix behavior of checkbox "generate my password" in password reset screen, update your custom `mail.tpl` (see `commit <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/7875d3c762649aa401c16e8546f2a81a24c9019a>`__)

To have the new tooltip feature on IDP choice screen, update your custom `idpchoice.tpl` (see `commit <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/15508470b6285a08e178f914fc3c828489f47e47#9b667b5f99a71a2740979a69f8baa66120a6471e>`__)

For the message box in menu when no applications are allowed, update your custom `menu.tpl` (see `commit <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/d6aa04291f74a92a04177ded34ac416caf0c78a2>`__)

For the new password policy balcklist feature, update your custom `passwordpolicy.tpl` (see `commit <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/merge_requests/318/diffs?commit_id=a1a6c2b84b9d5852d4561709d8c78f4b836cbacb#25b8124a904b66761e518050b617b093ca6ea929>`__)

New template files that should be linked or copied in your custom theme:

* `generic2fregister.tpl`
* `password2fcheck.tpl`
* `password2fregister.tpl`

If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.

2.0.15
------

Re-send 2FA code
^^^^^^^^^^^^^^^^

The :doc:`mail <mail2f>`, :doc:`external <external2f>` and :doc:`REST <rest2f>` based 2FA types can now re-send the user code if delivery failed for some reason. If you use custom templates, you must update ``ext2fcheck.tpl``

.. code:: diff

    --- a/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/ext2fcheck.tpl
    @@ -26,6 +26,12 @@
         </button>
       </div>
       <div class="buttons">
    +    <TMPL_IF "RESENDTARGET">
    +    <button type="submit" class="btn btn-primary" formaction="<TMPL_VAR "RESENDTARGET">">
    +      <span class="fa fa-repeat"></span>
    +      <span trspan="resendCode">Re-send code</span>
    +    </button>
    +    </TMPL_IF>
         <a href="<TMPL_VAR NAME="PORTAL_URL">?cancel=1&skin=<TMPL_VAR NAME="SKIN">" class="btn btn-primary" role="button">
           <span class="fa fa-home"></span>
           <span trspan="cancel">Cancel</span>


If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.

Customizing the 2FA logo in the registration screen
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The 2FA registration screen now displays the custom logo and label set in configuration. If you use custom templates, you should update ``2fregisters.tpl``

.. code:: diff

	@@ -77,10 +77,16 @@
		 <div class="card border-secondary">
		   <div class="card-body py-3">
		   <a href="<TMPL_VAR NAME="URL">" class="nodecor">
	-        <img src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/<TMPL_VAR NAME="LOGO">" alt="<TMPL_VAR NAME="CODE">2F" title="<TMPL_VAR NAME="CODE">2F" />
	+        <img src="<TMPL_VAR NAME="STATIC_PREFIX"><TMPL_VAR NAME="SKIN">/<TMPL_VAR NAME="LOGO">" alt="<TMPL_VAR NAME="CODE">2f" title="<TMPL_VAR NAME="LABEL">" />
		   </a>
		   </div>
	-      <div class="card-footer text-white text-uppercase bg-secondary"><TMPL_VAR NAME="CODE">2F</div>
	+      <div class="card-footer text-white text-uppercase bg-secondary">
	+      <TMPL_IF LABEL>
	+        <p><TMPL_VAR NAME="LABEL"></p>
	+      <TMPL_ELSE>
	+        <p trspan="<TMPL_VAR NAME="CODE">2f"></p>
	+      </TMPL_IF>
	+      </div>
		 </div>
		 </div>
		 </TMPL_LOOP>

If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.

Remember authentication choice
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A :doc:`new plugin<rememberauthchoice>` can be enabled to display a checkbox in :doc:`authentication choice<authchoice>` module to allow users remembering their choice, which will automatically redirect them to the selected choice the next time they connect to the portal.

If you use custom templates, you should update ``login.tpl``

.. code:: diff

    --- a/lemonldap-ng-portal/site/templates/bootstrap/login.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/login.tpl
    @@ -66,6 +66,12 @@

                 <TMPL_IF NAME="sslform">
                   <TMPL_INCLUDE NAME="sslformChoice.tpl">
    +
    +              <!-- Remember my authentication choice for this module -->
    +              <TMPL_IF NAME="REMEMBERAUTHCHOICE">
    +                <input type="hidden" id="rememberauthchoice" name="rememberauthchoice" value="<TMPL_IF NAME="REMEMBERAUTHCHOICEDEFAULTCHECKED">true</TMPL_IF>" />
    +              </TMPL_IF>
    +
                 </TMPL_IF>

                 <TMPL_IF NAME="gpgform">
    @@ -92,6 +98,11 @@

                   </div>

    +              <!-- Remember my authentication choice for this module -->
    +              <TMPL_IF NAME="REMEMBERAUTHCHOICE">
    +                <input type="hidden" id="rememberauthchoice" name="rememberauthchoice" value="<TMPL_IF NAME="REMEMBERAUTHCHOICEDEFAULTCHECKED">true</TMPL_IF>" />
    +              </TMPL_IF>
    +
                 </TMPL_IF>

               </form>
    @@ -104,6 +115,34 @@

         </div> <!-- end authMenu -->

    +    <TMPL_IF NAME="REMEMBERAUTHCHOICE">
    +    <div class="input-group col-md-6 offset-md-3">
    +
    +      <!-- Global checkbox for remembering the authentication choice for all modules -->
    +      <div id="globalrememberauthchoicecontainer" class="input-group-prepend input-group">
    +        <div class="input-group-text">
    +          <input type="checkbox" id="globalrememberauthchoice" name="globalrememberauthchoice" aria-describedby="globalrememberauthchoiceLabel" <TMPL_IF NAME="REMEMBERAUTHCHOICEDEFAULTCHECKED">checked</TMPL_IF> />
    +          <input id="rememberCookieName" name="rememberCookieName" type="hidden" value="<TMPL_VAR NAME="REMEMBERAUTHCHOICECOOKIENAME">">
    +        </div>
    +          <p class="form-control">
    +            <label id="globalrememberauthchoiceLabel" for="globalrememberauthchoice" trspan="rememberChoice">Remember my choice</label>
    +          </p>
    +      </div>
    +
    +      <!-- Timer + stop button for triggering the remembered authentication choice -->
    +      <div id="remembertimercontainer" class="input-group">
    +        <p class="form-control">
    +          <span id="remembertimer"><TMPL_VAR NAME="REMEMBERAUTHCHOICETIMER"></span>
    +          <label id="rememberTimerLabel" trspan="rememberTimerLabel">s before automatic authentication</label>
    +        </p>
    +        <input id="rememberStopped" name="rememberStopped" type="hidden" value="">
    +        <div class="input-group-append inout-group">
    +          <button class="btn btn-danger" id="buttonRememberStopped"><i class="fa fa-stop-circle-o"></i> Stop</button>
    +        </div>
    +      </div>
    +    </div>
    +    </TMPL_IF>
    +
       </TMPL_IF>

       <TMPL_IF NAME="DISPLAY_FORM">

Copy also ``styles.min.css`` and ``skin.min.js`` from ``bootstrap`` into your custom theme.

If you are using the default templates from the ``bootstrap`` theme, you don't need to change anything.


2.0.14
------


If you defined the "Register page URL" or the password "Reset page URL" to an external application, you need to fix the ``standardform.tpl`` template by applying the following patch:

.. code:: diff

    diff --git a/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl b/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    index 3a6256e59..d5192f0ce 100644
    --- a/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    +++ b/lemonldap-ng-portal/site/templates/bootstrap/standardform.tpl
    @@ -48,14 +48,14 @@

     <div class="actions">
       <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
    -  <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAIL_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
    +  <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAIL_URL"><TMPL_UNLESS NAME="MAIL_URL_EXTERNAL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF></TMPL_UNLESS>">
         <span class="fa fa-info-circle"></span>
         <span trspan="resetPwd">Reset my password</span>
       </a>
       </TMPL_IF>

       <TMPL_IF NAME="DISPLAY_UPDATECERTIF">
    -     <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAILCERTIF_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
    +     <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAILCERTIF_URL"><TMPL_UNLESS NAME="MAILCERTIF_URL_EXTERNAL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF></TMPL_UNLESS>">
             <span class="fa fa-refresh"></span>
             <span trspan="certificateReset">Reset my certificate</span>
          </a>
    @@ -69,7 +69,7 @@
       </TMPL_IF>

       <TMPL_IF NAME="DISPLAY_REGISTER">
    -    <a class="btn btn-secondary" href="<TMPL_VAR NAME="REGISTER_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
    +    <a class="btn btn-secondary" href="<TMPL_VAR NAME="REGISTER_URL"><TMPL_UNLESS NAME="REGISTER_URL_EXTERNAL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF></TMPL_UNLESS>">
           <span class="fa fa-plus-circle"></span>
           <span trspan="createAccount">Create an account</span>
         </a>



2.0.13
------

Some ``autocomplete`` attributes have been added to improve accessibility in the following files: ``checkdevops.tpl``, ``checkuser.tpl``, ``register.tpl``, ``ext2fcheck.tpl``, ``totp2fcheck.tpl``.



2.0.12
------

Email templates
^^^^^^^^^^^^^^^

If you customized the HTML email templates, you must update them to use HTML::Template variables (this was changed to fix XSS injections).

In the following files: ``mail_2fcode.tpl`` ``mail_certificateReset.tpl`` ``mail_footer.tpl`` ``mail_password.tpl`` ``mail_register_done.tpl`` ``mail_certificateConfirm.tpl`` ``mail_confirm.tpl`` ``mail_header.tpl`` ``mail_register_confirm.tpl``

Replace the following variables:


.. list-table::
   :header-rows: 1

   * - Old syntax
     - New syntax
   * - ``$code``
     - ``<TMPL_VAR NAME="code" ESCAPE=HTML>``
   * - ``$url``
     - ``<TMPL_VAR NAME="url" ESCAPE=HTML>``
   * - ``$login``
     - ``<TMPL_VAR NAME="login" ESCAPE=HTML>``
   * - ``$password``
     - ``<TMPL_VAR NAME="password" ESCAPE=HTML>``
   * - ``$firstname``
     - ``<TMPL_VAR NAME="firstname" ESCAPE=HTML>``
   * - ``$lastname``
     - ``<TMPL_VAR NAME="lastname" ESCAPE=HTML>``

Replace all other variables such as ``$cn`` by ``<TMPL_VAR NAME="session_cn" ESCAPE=HTML>``.

Login form
^^^^^^^^^^
To benefit from the new feature allowing to show password on login form, adapt ``standardform.tpl`` (see `changes <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/bdeb1e70d98ddc89316b0912d9d5ee6d11d0bee5#fbbcec1fdc36cc042eeaa83274a32ef2231fe977_23_23>`__)

To disable password store in browser when changing password (this was already possible for login form), adapt ``password.tpl`` (see `changes <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/466b6a3241fff5013d27b3dd22982e5e26ed7dfb#0ae060b3d1e289f08f510c268ed72de5dcafe425_36_35>`__)

To fix placeholder display in password field when password store is disabled in browser, adapt ``password.tpl`` (see `changes <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/commit/547d80985290495d33ed72a388e9ddf482980354#fbbcec1fdc36cc042eeaa83274a32ef2231fe977_21_20>`__)

Simplification of TOTP options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In ``totp2fregister.tpl`` template:

* Move ``#divToHide`` from the ``.col-md-6`` div to the ``.card`` div
* Change::

  <pre id="serialized"></pre>

* to::

  <br/><tt id="secret"></tt>

* Remove the ``#changekey`` button

FindUser, CheckDevOps templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Some changes have been made to include new plugins (FindUser and CheckDevOps), you need to report them only if you have a custom theme and you want to use these plugins


2.0.11
------

If you created your own skin and modified some template files, you may need to update them.
No change is required if you are using the default ``bootstrap`` theme.

A new plugin has been introduced, in beta version: :doc:`FindUser <finduser>`. It requires a modification of ``login.tpl`` to include ``finduser.tpl``.


2.0.10
------

2FA manager
^^^^^^^^^^^

If you use a custom theme, even if you did not modify ``2fregisters.tpl``, you need to copy ``skin.min.js`` from the ``htdocs/static/bootstrap/js`` folder to your custom theme's ``js`` folder.

If you modified ``2fregisters.tpl`` you need to add the ``remove2f`` class to the button that triggers second factor removal:

.. code-block:: diff

   - <span device='<TMPL_VAR NAME="type">' epoch='<TMPL_VAR NAME="epoch">' class="btn btn-danger" role="button">
   + <span device='<TMPL_VAR NAME="type">' epoch='<TMPL_VAR NAME="epoch">' class="btn btn-danger remove2f" role="button">

Or, better yet, integrate the changes in ``2fregisters.tpl`` into your custom theme to benefit from the `new 2F removal confirmation dialog <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2438>`__

Checkboxes
^^^^^^^^^^

A CSS change has been done in ``styles.css`` to avoid checkbox labels overflow. See `issue 2301 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2301>`__.

The ``form-check-input`` class is missing in ``register.tpl`` and ``notifinclude.tpl``. See `issue 2374 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2374>`__.

Password checker
^^^^^^^^^^^^^^^^

Input id values have been modified in ``mail.tpl`` to work with password checker. See `issue 2355 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2355>`__.

Tables caption
^^^^^^^^^^^^^^

Tables captions have been added in ``sessionArray.tpl``. See `issue 2356 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2356>`__.

Stay connected
^^^^^^^^^^^^^^

A small change is required in ``checklogins.tpl`` for `issue 2365 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2365>`__.

Other changes needed in ``2fchoice.tpl``, ``ext2check.tpl`` and ``totp2fcheck.tpl`` for `issue 2366 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2366>`__.

Mails
^^^^^

The HTML ``alt`` attribute has been added on ``img`` in all ``mail_*.tpl``. See `issue 2422 <https://gitlab.ow2.org/lemonldap-ng/lemonldap-ng/-/issues/2422>`__.

