Location detection plugin
=========================

This plugin use GeoIP database and browser detection module to get city, country, browser and OS from connected user.

Required dependencies
---------------------

You need to install the following Perl modules: ``HTTP::BrowserDetect``, ``GeoIP2``.

GeoIP database
--------------

Create an account on `<https://www.maxmind.com/en/home>`__ and put credentials in ``/etc/GeoIP.conf``:

.. code-block::

    # Enter your account ID and license key below. These are available from
    # https://www.maxmind.com/en/my_license_key. If you are only using free
    # GeoLite databases, do not uncomment these lines.
    AccountID 111111
    LicenseKey xxxxxx

Update database:

.. code-block:: shell

    geoipupdate -v

The database files should present in ``/var/lib/GeoIP2/``.

Configuration
-------------

In section "General Parameters > Plugins > Location detection", you can set these parameters.

-  **Parameters**:

   -  **Enable plugin**: Enable/disable this plugin
   -  **Path to GeoIP database**: Full path to GeoIP2 database
   -  **Information requested for IP**: Choose ``city`` or ``¢ountry``
   -  **Information requested for User Agent**: Choose ``browser`` or ``os``

Usage
-----

When plugin is enabled, new informations will be stored in session:

* ``_location_detect_env_ua``: User Agent information
* ``_location_detect_env_ip``: GeoIP information
* ``_location_detect_env_display``: Both User Agent and GeoIP information

To see them in :doc:`login history<loginhistory>`, you can add them to the list of session data to store.

You can also use these information in 2FA rules, access rules, adaptive authentication rules...

For example, to use these information in the :doc:`new location warning plugin<newlocationwarning>`, use ``_location_detect_env`` for ``newLocationWarningLocationAttribute`` and ``_location_detect_env_display`` for ``newLocationWarningLocationDisplayAttribute``.
