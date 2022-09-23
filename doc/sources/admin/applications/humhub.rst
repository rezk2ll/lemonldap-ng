HumHub
======

|image0|

Présentation
------------

`HumHub <https://humhub.org/>`__ is a free and open-source social
network written on top of the `Yii2 PHP
framework <https://www.yiiframework.com/>`__ that provides an easy to
use toolkit for creating and launching your own social network.

Unauthenticated users may connect using a login form against HumHub
local database or a LDAP directory, or choose which authentication
service they want to use.

Administrator can configure one or several OAuth, OAuth2 or OIDC
authentication services to be displayed as buttons on the login page.

With :doc:`OpenID Connect<>` authentication service, users successfully
authenticated by LemonLDAP::NG will be registered in HumHub upon their
first login.


.. danger::

    HumHub retrieves a user from his username and the
    authentication service he came through. As a result, a former local or
    LDAP user will be rejected when trying to authenticate using another
    authentication service. See
    :doc:`Migrate former local or ldap Humhub account to connect through SSO<>`


OpenID Connect
--------------


.. note::

    This set-up works with option enablePrettyUrl activated in
    Humhub. If not activated, rewrite URL in Humhub HTTP server and allowed
    redirect URL in LemonLDAP needs to be adapted to work with the non
    pretty URL format.

Configuring HumHub
~~~~~~~~~~~~~~~~~~

First disable LDAP (Administration > Users section) and delete (or
:doc:`migrate<>`) any local users whose username or email are
conflicting with the username or email of your OIDC users.

Then install and configure the `OIDC connector for
humhub <https://github.com/Worteks/humhub-auth-oidc>`__ extension using
composer :

-  Install composer.

-  Consider using prestissimo, to speed up composer update command (4x
   faster):

::

   composer global require hirak/prestissimo

- Go to ``{humhub_home}`` folder

-  Check if composer.json file is present. If not, download it for your
   current version:

::

   wget https://raw.githubusercontent.com/humhub/humhub/v1.3.15/composer.json

-  Install the connector as a dependency:

::

   composer require --no-update --update-no-dev worteks/humhub-auth-oidc
   composer update worteks/humhub-auth-oidc  --no-dev --prefer-dist -vvv


.. note::

    If you just need to update the connector, change its version
    in composer.json and run the above composer update command.

- Edit `{humhub_home}/protected/config/common.php` with the client configuration :

::

   'components' => [
     'authClientCollection' => [
       'clients' => [
         // ...
         'lemonldapng' => [
           'class' => 'worteks\humhub\authclient\OIDC',
           'domain' => 'https://auth.example.com',
           'clientId' => 'myClientId', // Client ID for this RP in LemonLDAP
           'clientSecret' => 'myClientSecret', // Client secret for this RP in LemonLDAP
           'defaultTitle' => 'auth.example.com', // Text displayed in login button
           'cssIcon' => 'fa fa-lemon-o', // Icon displayed in login button
         ],
       ],
       // ...
   ]

- Edit ``{humhub_home}/protected/config/web.php`` to disconnect users from LemonLDAP::NG after they logged out of Humhub:

::

   return [
    // ...
    'modules' => [
     'user' => [
      'logoutUrl' => 'https://auth.domain.com/?logout=1',
     ],
    ]
   ];

User can now log in through SSO using a button on humhub logging page.
If you want to remove this intermediate login page, so user are
automatically logged in through SSO when they first access Humhub, you
can set up a redirection in the http server in front of the application
:

-  Example in apache

::

   RewriteEngine On
   RewriteCond %{QUERY_STRING} !nosso [NC]
   RewriteRule "^/user/auth/login$" "/user/auth/external?authclient=lemonldapng" [L,R=301]

-  Example in nginx

::

   if ($query_string !~ "nosso"){
     rewrite ^/user/auth/login$ /user/auth/external?authclient=lemonldapng permanent;
   }

If the authentication was successful but the user could not be
registered in Humhub (which often happen if there is a conflict between
source, username or email), Humhub will redirect to the login page to
display the error, which trigger a redirection to the portal, ultimately
triggering a loop error while registration error is not displayed.

To change this behavior and display the registration error,
AuthController.onAuthSuccess method needs to be adapted so redirect to
SSO will be bypassed when a registration error occured. This works for
version 1.3.15 :

- Go to ``{humhub_home}`` folder
- Execute

::

   sed -i "s|return \$this->redirect(\['/user/auth/login'\]);|return \$this->redirect(['/user/auth/login','nosso'=>'showerror']);|" protected/humhub/modules/user/controllers/AuthController.php

Configuring LemonLDAP
~~~~~~~~~~~~~~~~~~~~~

If not done yet, configure LemonLDAP::NG as an
:doc:`OpenID Connect service<..//openidconnectservice>`.

Then, configure LemonLDAP::NG to recognize your HumHub instance as a
valid :doc:`new OpenID Connect Relying Party<..//idpopenidconnect>`
using the following parameters:

* **Client ID**: the same you set in HumHub configuration
* **Client Secret**: the same you set in HumHub configuration
* Add the following **exported attributes**
   * **given_name**: user's givenName attribute
   * **family_name**: user's sn attribute
   * **email**: user's mail attribute
* **Redirect URIs** containing your Yii2 auth client ID.

Configuration sample using CLI:

::

     $ /usr/libexec/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
         addKey \
           oidcRPMetaDataExportedVars/humhub given_name givenName \
           oidcRPMetaDataExportedVars/humhub family_name sn \
           oidcRPMetaDataExportedVars/humhub email mail \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsClientID myClientId \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsClientSecret myClientSecret \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsRedirectUris 'https://humhub.example.com/user/auth/external?authclient=lemonldapng'  \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsPostLogoutRedirectUris 'https://humhub.example.com' \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsIDTokenSignAlg RS512 \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsIDTokenExpiration 3600 \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsAccessTokenExpiration 3600 \
           oidcRPMetaDataOptions/humhub oidcRPMetaDataOptionsBypassConsent 1

Migrate former local or ldap Humhub account to connect through SSO
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You need to manually update Humhub database to swith authentication mode
to LemonLDAP::NG.

Table "user":

* Columns "username" and "email" should match exactly OIDC sub and email attributes ;
* If former ldap user, change column "auth_mode" to "local".

Table "user_auth":

* Add an entry with user_id, username and "lemonldapng" as source (or the name you chose in your connector configuration) :

::

   +---------+-------------+-------------+
   | user_id | source      | source_id   |
   +---------+-------------+-------------+
   |       4 | lemonldapng | jdoe        |

Troubleshooting
~~~~~~~~~~~~~~~

If LemonLDAP login page freezes because of a browser security blockage,
adapt security's CSP Form Action to allow HumHub host :

::

    $ /usr/libexec/lemonldap-ng/bin/lemonldap-ng-cli -yes 1 \
         set \
           cspFormAction "'self' https://*.example.com"

.. |image0| image:: /applications/humhub_logo.png
   :class: align-center

