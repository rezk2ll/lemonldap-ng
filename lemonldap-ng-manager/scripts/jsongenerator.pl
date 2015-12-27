#!/usr/bin/perl -Ilib/ -I../lemonldap-ng-common/lib/ -w

use Lemonldap::NG::Manager::Build;

Lemonldap::NG::Manager::Build->run(
    structFile            => "site/static/struct.json",
    confTreeFile          => "site/static/js/conftree.js",
    managerConstantsFile  => "lib/Lemonldap/NG/Manager/Constants.pm",
    managerAttributesFile => 'lib/Lemonldap/NG/Manager/Attributes.pm',
    defaultValuesFile =>
      "../lemonldap-ng-common/lib/Lemonldap/NG/Common/Conf/DefaultValues.pm",
);

