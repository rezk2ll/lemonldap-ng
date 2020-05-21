PHP (Symfony)
=============

|image0|

Presentation
------------

`Symfony <https://symfony.com/>`__ is the well-known PHP framework. It
is intended to ease the development of PHP applications.

Symfony provides many methods conventions to authenticate users (basic,
ldap,...) and to load external user sources (ldap, database). The method
presented here relies on the "remote_user" method. (in security
firewall)

Configuration
-------------

Follow these step to protect your application using the "REMOTE_USER"
HTTP header.

1. Adapt the app/config/security.yml configuration file as below:

.. code-block:: yaml

   security:

       encoders:
           AppBundle\Security\User\HeaderUser: plaintext

       providers:
           header:
               id: AppBundle\Security\User\HeaderUserProvider

       firewalls:
           dev:
               pattern: ^/(_(profiler|wdt)|css|images|js)/
               security: false

           main:
               pattern: ^/
               remote_user:
                   user: HTTP_REMOTE_USER
               provider: header

-  encoders : define a password hashing scheme (useless in our case, but
   the parameter is mandatory)
-  providers : define the user providers (even virtual)
-  remote_user : define the authentication method to "assume the user is
   already authenticated and get an http variable to know his username"
-  user : define the HTTP header containing the username
-  provider : references the previously defined provider owning the user
   data (in our scenario, a virtual)

2. Define a "header user" class

Create the file src/AppBundle/Security/User/HeaderUser.php :

.. code-block:: php

   <?php

   // src/Security/User/HeaderUser.php
   namespace AppBundle\Security\User;

   use Symfony\Component\Security\Core\User\UserInterface;
   use Symfony\Component\Security\Core\User\EquatableInterface;

   class HeaderUser implements UserInterface, EquatableInterface
   {
       private $username;
       private $password;
       private $salt;
       private $roles;

       public function __construct($username, $password, $salt, array $roles)
       {
           $this->username = $username;
           $this->password = $password;
           $this->salt = $salt;
           $this->roles = $roles;
       }

       public function getRoles()
       {
           return $this->roles;
       }

       public function getPassword()
       {
           return $this->password;
       }

       public function getSalt()
       {
           return $this->salt;
       }
       public function getUsername()
       {
           return $this->username;
       }

       public function eraseCredentials()
       {
       }

       public function isEqualTo(UserInterface $user)
       {
           if (!$user instanceof HeaderUser) {
               return false;
           }

           if ($this->username !== $user->getUsername()) {
               return false;
           }

           //if ($this->password !== $user->getPassword()) {
           //    return false;
           //}

           return true;
       }
   }
   ?>

3. Define a "header user provider" class relying on the previous class

Create the file src/AppBundle/Security/User/HeaderUserProvider.php :

.. code-block:: php

   <?php

   // src/Security/User/HeaderUserProvider.php
   namespace AppBundle\Security\User;

   use AppBundle\Security\User\HeaderUser;
   use Symfony\Component\Security\Core\User\UserProviderInterface;
   use Symfony\Component\Security\Core\User\UserInterface;
   use Symfony\Component\Security\Core\Exception\UsernameNotFoundException;
   use Symfony\Component\Security\Core\Exception\UnsupportedUserException;

   class HeaderUserProvider implements UserProviderInterface
   {
       public function loadUserByUsername($username)
       {

           if ($username) {

               $password = "dummy";
               $salt = "";
               $roles = array('ROLE_USER');

               return new HeaderUser($username, $password, $salt, $roles);
           }

           throw new UsernameNotFoundException(
               sprintf('Username "%s" does not exist.', $username)
           );
       }

       public function refreshUser(UserInterface $user)
       {
           if (!$user instanceof HeaderUser) {
               throw new UnsupportedUserException(
                   sprintf('Instances of "%s" are not supported.', get_class($user))
               );
           }

           return $this->loadUserByUsername($user->getUsername());
       }

       public function supportsClass($class)
       {
           return HeaderUser::class === $class;
       }
   }

   ?>

References
----------

-  http://symfony.com/doc/current/security/pre_authenticated.html#remote-user-based-authentication
-  https://symfony.com/doc/current/security/custom_provider.html

.. |image0| image:: /applications/symfony_logo.png
   :class: align-center

