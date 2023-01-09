#!/usr/bin/perl -Ilemonldap-ng-manager/lib/ -Ilemonldap-ng-common/lib/ -w

use Lemonldap::NG::Manager::Build;

Lemonldap::NG::Manager::Build->run(
    structFile   => 'lemonldap-ng-manager/site/htdocs/static/struct.json',
    confTreeFile => 'lemonldap-ng-manager/site/htdocs/static/js/conftree.js',
    managerConstantsFile =>
      'lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/ReConstants.pm',
    managerAttributesFile =>
      'lemonldap-ng-manager/lib/Lemonldap/NG/Manager/Attributes.pm',
    defaultValuesFile =>
      'lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/DefaultValues.pm',
    confConstantsFile =>
      'lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/Constants.pm',
    firstLmConfFile => '_example/conf/lmConf-1.json',
    reverseTreeFile =>
      'lemonldap-ng-manager/site/htdocs/static/reverseTree.json',
    portalConstantsFile =>
      'lemonldap-ng-portal/lib/Lemonldap/NG/Portal/Main/Constants.pm',
    handlerStatusConstantsFile =>
      'lemonldap-ng-handler/lib/Lemonldap/NG/Handler/Lib/StatusConstants.pm',
    docConstantsFile => 'doc/sources/admin/error_codes.rst',
);

