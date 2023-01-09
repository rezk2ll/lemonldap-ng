Decrypt value plugin
====================

This plugin allows us to decrypt ciphered values. LL::NG can be
configured to send encrypted values to protected applications by using
:doc:`extended functions<extendedfunctions>`.

Configuration
-------------

Just enable it in the Manager (section “plugins”) by setting a rule.
DecryptValue plugin can be allowed or denied for specific users.

-  **Parameters**:

   -  **Use rule**: Select which users may use this plugin
   -  **Decrypt functions**: Set functions used for decrypting ciphered
      values. Each function is tested until one succeeds. Let it blank
      to use internal ``decrypt`` extended function.


.. attention::

    The ciphered value is the first parameter passed to custom functions.

    The ``Encryption key`` is passed to custom funtions as second parameter
    (see :ref:`Security settings<security-configure-security-settings>`).

    Custom functions must be defined into
    ``My::Plugin`` and set:

    ::

       My::Plugin::function1 My::Plugin::function2
