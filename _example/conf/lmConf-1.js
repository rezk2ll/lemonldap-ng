{
   "portal" : "http://auth.__DNSDOMAIN__/",
   "persistentStorage" : "Apache::Session::File",
   "portalSkinBackground" : "1280px-Cedar_Breaks_National_Monument_partially.jpg",
   "globalStorageOptions" : {
      "LockDirectory" : "__SESSIONDIR__/lock",
      "Directory" : "__SESSIONDIR__",
      "generateModule" : "Lemonldap::NG::Common::Apache::Session::Generate::SHA256"
   },
   "passwordDB" : "Demo",
   "locationRules" : {
      "test2.__DNSDOMAIN__" : {
         "default" : "accept",
         "^/logout" : "logout_sso"
      },
      "manager.__DNSDOMAIN__" : {
         "default" : "$uid eq \"dwho\""
      },
      "test1.__DNSDOMAIN__" : {
         "^/logout" : "logout_sso",
         "default" : "accept"
      }
   },
   "cfgNum" : "1",
   "exportedVars" : {
      "UA" : "HTTP_USER_AGENT"
   },
   "authentication" : "Demo",
   "mailUrl" : "http://auth.__DNSDOMAIN__/mail.pl",
   "applicationList" : {
      "1sample" : {
         "catname" : "Sample applications",
         "test2" : {
            "options" : {
               "uri" : "http://test2.__DNSDOMAIN__/",
               "display" : "auto",
               "name" : "Application Test 2",
               "description" : "The same simple application displaying authenticated user",
               "logo" : "thumbnail.png"
            },
            "type" : "application"
         },
         "test1" : {
            "options" : {
               "logo" : "demo.png",
               "description" : "A simple application displaying authenticated user",
               "name" : "Application Test 1",
               "uri" : "http://test1.__DNSDOMAIN__/",
               "display" : "auto"
            },
            "type" : "application"
         },
         "type" : "category"
      },
      "3documentation" : {
         "officialwebsite" : {
            "type" : "application",
            "options" : {
               "logo" : "network.png",
               "display" : "on",
               "uri" : "http://lemonldap-ng.org/",
               "description" : "Official LemonLDAP::NG Website",
               "name" : "Offical Website"
            }
         },
         "localdoc" : {
            "options" : {
               "logo" : "help.png",
               "uri" : "http://manager.__DNSDOMAIN__/doc/",
               "display" : "on",
               "name" : "Local documentation",
               "description" : "Documentation supplied with LemonLDAP::NG"
            },
            "type" : "application"
         },
         "type" : "category",
         "catname" : "Documentation"
      },
      "2administration" : {
         "type" : "category",
         "manager" : {
            "options" : {
               "logo" : "configure.png",
               "uri" : "http://manager.__DNSDOMAIN__/manager.html",
               "display" : "auto",
               "name" : "WebSSO Manager",
               "description" : "Configure LemonLDAP::NG WebSSO"
            },
            "type" : "application"
         },
         "sessions" : {
            "type" : "application",
            "options" : {
               "logo" : "database.png",
               "uri" : "http://manager.__DNSDOMAIN__/sessions.html",
               "display" : "auto",
               "description" : "Explore WebSSO sessions",
               "name" : "Sessions explorer"
            }
         },
         "catname" : "Administration",
         "notifications" : {
            "type" : "application",
            "options" : {
               "logo" : "database.png",
               "uri" : "http://manager.__DNSDOMAIN__/notifications.html",
               "display" : "auto",
               "description" : "Explore WebSSO notifications",
               "name" : "Notifications explorer"
            }
         }
      }
   },
   "notificationStorage" : "File",
   "cfgAuthor" : "The LemonLDAP::NG team",
   "sessionDataToRemember" : {},
   "notification" : 1,
   "persistentStorageOptions" : {
      "Directory" : "__PSESSIONDIR__",
      "LockDirectory" : "__PSESSIONDIR__/lock"
   },
   "domain" : "__DNSDOMAIN__",
   "notificationStorageOptions" : {
      "dirName" : "__NOTIFICATIONDIR__"
   },
   "reloadUrls" : {
      "reload.__DNSDOMAIN__" : "http://reload.__DNSDOMAIN__/reload"
   },
   "cookieName" : "lemonldap",
   "securedCookie" : 0,
   "whatToTrace" : "_whatToTrace",
   "groups" : {},
   "macros" : {
      "_whatToTrace" : "$_auth eq 'SAML' ? \"$_user\\@$_idpConfKey\" : \"$_user\""
   },
   "timeout" : 72000,
   "demoExportedVars" : {
      "uid" : "uid",
      "cn" : "cn",
      "mail" : "mail"
   },
   "userDB" : "Demo",
   "exportedHeaders" : {
      "test1.__DNSDOMAIN__" : {
         "Auth-User" : "$uid"
      },
      "test2.__DNSDOMAIN__" : {
         "Auth-User" : "$uid"
      }
   },
   "loginHistoryEnabled" : 1,
   "registerUrl" : "http://auth.__DNSDOMAIN__/register.pl",
   "globalStorage" : "Apache::Session::File"
}
