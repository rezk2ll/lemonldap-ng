Applications
============

.. toctree::
   :hidden:

   applications/adfs
   applications/alfresco
   applications/aws
   applications/awx
   applications/bugzilla
   applications/bigbluebutton
   applications/confluence
   applications/cornerstone
   applications/discourse
   applications/django
   applications/dokuwiki
   applications/drupal
   applications/fusiondirectory
   applications/gerrit
   applications/gitea
   applications/gitlab
   applications/glpi
   applications/googleapps
   applications/grafana
   applications/grr
   applications/guacamole
   applications/humhub
   applications/iparapheur
   applications/itsm-ng
   applications/jitsimeet
   applications/liferay
   applications/limesurvey
   applications/mailman
   applications/matrix
   applications/mattermost
   applications/mediawiki
   applications/mobilizon
   applications/nextcloud
   applications/obm
   applications/odoo
   applications/office365
   applications/opencti
   applications/publik
   applications/phpldapadmin
   applications/redmine
   applications/rocketchat
   applications/roundcube
   applications/salesforce
   applications/sap
   applications/sharepoint
   applications/simplesamlphp
   applications/spring
   applications/symfony
   applications/sympa
   applications/tomcat
   applications/wekan
   applications/wikijs
   applications/wordpress
   applications/xwiki
   applications/zimbra

How to integrate
----------------

To integrate a Web application in LL::NG, you have the following
possibilities:

-  Protect the application with the Handler, and push user identity
   through HTTP headers. This is how main Access Manager products, like
   CA SiteMinder, are working. This also how Apache authentication
   modules are working, so if your application is compatible with Apache
   authentication (often called "external authentifcation"), then you
   can use the Handler.
-  Specific Handler: some applications can require a specific Handler,
   to manage preauthentication process for example.
-  CAS: your application is a CAS client, you can configure LL::NG as a
   :doc:`CAS server<idpcas>`.
-  SAML: your application is a SAML Service Provider, you can configure
   LL::NG as a :doc:`SAML Identity Provider<idpsaml>`.
-  OpenID Connect: your application is a OpenID Connect Relying Party,
   you can configure LL::NG as a
   :doc:`OpenID Connect Provider<idpopenidconnect>`.

If none of above methods is available, you can try:

-  :doc:`HTTP Auth-Basic<applications/authbasic>`: replay Auth Basic
   authentication
-  :doc:`Form replay<formreplay>`: replay form based authentication

Application list
----------------

================================================================= ==================================================== ============ ================ === ==== ====
Application                                                       Configuration guide                                  HTTP headers Specific Handler CAS SAML OIDC
================================================================= ==================================================== ============ ================ === ==== ====
.. image:: applications/microsoft-adfs.png                        :doc:`ADFS<applications/adfs>`                                                         ✔
.. image:: applications/alfresco_logo.png                         :doc:`Alfresco<applications/alfresco>`               ✔                                 ✔
.. image:: applications/logo_amazon_web_services.jpg              :doc:`Amazon Web Services<applications/aws>`                                           ✔
.. image:: applications/logo-awx.png                              :doc:`AWX (Ansible Tower)<applications/awx>`                                           ✔
.. image:: applications/bigbluebutton-logo.png                    :doc:`BigBlueButton<applications/bigbluebutton>`                                            ✔
.. image:: applications/bugzilla_logo.png                         :doc:`Bugzilla<applications/bugzilla>`               ✔
.. image:: applications/confluence.png                            :doc:`Confluence<applications/confluence>`                                             ✔    ✔
.. image:: applications/csod_logo.png                             :doc:`Cornerstone<applications/cornerstone>`                                           ✔
.. image:: applications/discourse.jpg                             :doc:`Discourse<applications/discourse>`                                               ✔    ✔
.. image:: applications/django_logo.png                           :doc:`Django<applications/django>`                   ✔
.. image:: applications/dokuwiki_logo.png                         :doc:`Dokuwiki<applications/dokuwiki>`               ✔
.. image:: applications/drupal_logo.png                           :doc:`Drupal<applications/drupal>`                   ✔
.. image:: applications/fusiondirectory-logo.jpg                  :doc:`FusionDirectory<applications/fusiondirectory>` ✔
.. image:: applications/gerrit_logo.png                           :doc:`Gerrit<applications/gerrit>`                                                          ✔
.. image:: applications/gitlab_logo.png                           :doc:`Gitlab<applications/gitlab>`                                                     ✔    ✔
.. image:: applications/gitea_logo.png                            :doc:`Gitea<applications/gitea>`                                                            ✔
.. image:: applications/glpi_logo.png                             :doc:`GLPI<applications/glpi>`                       ✔
.. image:: applications/googleapps_logo.png                       :doc:`Google Apps<applications/googleapps>`                                            ✔
.. image:: applications/grafana_logo.png                          :doc:`Grafana<applications/grafana>`                                                        ✔
.. image:: applications/grr_logo.png                              :doc:`GRR<applications/grr>`                         ✔
.. image:: applications/guacamole.png                             :doc:`Apache Guacamole<applications/guacamole>`      ✔                             ✔        ✔
.. image:: applications/humhub_logo.png                           :doc:`HumHub<applications/humhub>`                                                          ✔
.. image:: applications/iparapheur_logo.png                       :doc:`i-Parapheur<applications/iparapheur>`          ✔
.. image:: applications/itsm-ng.png                               :doc:`ITSM-NG<applications/itsm-ng>`                 ✔                                      ✔
.. image:: applications/logo-jitsimeet.png                        :doc:`Jitsi Meet<applications/jitsimeet>`            ✔
.. image:: applications/liferay_logo.png                          :doc:`Liferay<applications/liferay>`                 ✔
.. image:: applications/limesurvey_logo.png                       :doc:`LimeSurvey<applications/limesurvey>`           ✔
.. image:: applications/mailman.jpg                               :doc:`Mailman<applications/mailman>`                                                        ✔
.. image:: applications/matrix_logo.png                           :doc:`Matrix<applications/matrix>`                                                          ✔
.. image:: applications/mattermost_logo.png                       :doc:`Mattermost<applications/mattermost>`                                                  ✔
.. image:: applications/mediawiki_logo.png                        :doc:`Mediawiki<applications/mediawiki>`             ✔
.. image:: applications/mobilizon_logo.jpg                        :doc:`Mobilizon<applications/mobilizon>`             ✔
.. image:: applications/nextcloud-logo.png                        :doc:`NextCloud<applications/nextcloud>`                                               ✔
.. image:: applications/obm_logo.png                              :doc:`OBM<applications/obm>`                         ✔
.. image:: applications/odoo_logo.png                             :doc:`Odoo<applications/odoo>`                                                         ✔
.. image:: applications/logo_office_365.png                       :doc:`Office 365<applications/office365>`                                              ✔
.. image:: applications/opencti.png                               :doc:`OpenCTI<applications/opencti>`                                                   ✔    ✔
.. image:: applications/logo-publik.png                           :doc:`Publik<applications/publik>`                                                          ✔
.. image:: applications/phpldapadmin_logo.png                     :doc:`phpLDAPAdmin<applications/phpldapadmin>`       ✔
.. image:: applications/redmine_logo.png                          :doc:`Redmine<applications/redmine>`                                                        ✔
.. image:: applications/rocketchat-logo.png                       :doc:`Rocketchat<applications/rocketchat>`                                             ✔
.. image:: applications/roundcube_logo.png                        :doc:`Roundcube<applications/roundcube>`             ✔
.. image:: applications/salesforce-logo.jpg                       :doc:`SalesForce<applications/salesforce>`                                             ✔
.. image:: applications/SAPLogo.gif                               :doc:`SAP<applications/sap>`                         ✔                                 ✔
.. image:: applications/sharepoint.png                            :doc:`Sharepoint<applications/sharepoint>`                                                  ✔
.. image:: applications/simplesamlphp_logo.png                    :doc:`simpleSAMLphp<applications/simplesamlphp>`                                       ✔
.. image:: applications/spring_logo.png                           :doc:`Spring<applications/spring>`                   ✔
.. image:: applications/symfony_logo.png                          :doc:`Symfony<applications/symfony>`                 ✔
.. image:: applications/sympa_logo.png                            :doc:`Sympa<applications/sympa>`                     ✔                             ✔
.. image:: applications/tomcat_logo.png                           :doc:`Tomcat<applications/tomcat>`                   ✔
.. image:: applications/wekan-logo.png                            :doc:`Wekan<applications/wekan>`                                           ✔
.. image:: applications/wiki.js.svg                               :doc:`Wiki.js<applications/wikijs>`                                           ✔
.. image:: applications/wordpress_logo.png                        :doc:`Wordpress<applications/wordpress>`                                           ✔
.. image:: applications/xwiki.png                                 :doc:`XWiki<applications/xwiki>`                     ✔
.. image:: applications/zimbra_logo.png                           :doc:`Zimbra<applications/zimbra>`                                ✔
================================================================= ==================================================== ============ ================ === ==== ====
