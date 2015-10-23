# Lemonldap::NG::Manager TODO list

* Check for eval with SAML
* userInfo && userWarn
* Icon picker for application logo
* Change documentation lang when changing language

## Bugs

* After an Apache restart, if Manager is loaded first, portal cannot be loaded
* Authentication parameters:
  * No input is displayed when Multi is choosen in authentication modules
  * Specific backend branch do not appear when module is choosen from authParams.html, only when choosen from the child entry
  * Filter displayed backend with Choice/Multi. See also https://jira.ow2.org/browse/LEMONLDAP-833 
* We always get "All sessions may be lost and you must restart all your Apache servers" error
* When we get needConfirm: 1 in save response, configuration is already saved. It should only be saved after confirmation. We should have a "cancel" button in confirmation window to refuse the changes.
* RSA public/private keys: the regexp tests RSAPublicKey and RSAPrivateKey always fail (Attributes.pm).

## Configuration management

* `currentConf` => `$req` instead of `$self`
* PSGI: improve log system (syslog,...)
* Forms:
  * issuers resume
* Possibility to delete a configuration

### Struct & datas

* Tests for new confs
* default values: TODO, deliver a "0" conf when no conf is available
* Forms:
  * file: load from URL + download
  * Grant session rule
  * OpenID white/black list
  * oidcOpMetadata ?
  * POST replay fields

* import from JSON
* Order of categories

### REST API:

### PSGI authentication

* JQuery module to add `$._llngAjax`
* Angular module to add $llngHttp

## Sessions explorer

## Optimization

* Create modules to get needed values for a new conf without using
  `Common::Conf::Attributes`
* Then delete essential default values in running modules: they have to be
  provided by any configuration
* Use JSON to store datas:
  * configuration: the new `File` will look at the first character. If not `{`,
    it will call old `File` functions
  * sessions: new Apache::Session::Serialize::JSON module

## Doc

* Wiki doc
* Developer corner:
  * adding a configurationkey
  * adding a data type

## Question more

* Phonegap
* Ionic
