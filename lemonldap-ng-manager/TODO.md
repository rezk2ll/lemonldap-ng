# Lemonldap::NG::Manager TODO list

* Check for eval with SAML
* userInfo && userWarn
* Help interface
* Manage cfgAuthor
* Display input when Multi is choosen in authentication modules
* Icon picker for application logo

## Configuration management

* `currentConf` => `$req` instead of `$self`
* PSGI: improve log system (syslog,...)
* Forms:
  * issuers resume

### Struct & datas

* Tests for new confs
* default values: TODO, deliver a "0" conf when no conf is available
* Forms:
  * file: load from URL + download
  * Grant session rule
  * OpenID white/black list
  * oidcOpMetadata ?

* import from JSON
* Order of categories

### REST API:

### PSGI authentication

* JQuery module to add `$._llngAjax`
* Angular module to add $llngHttp

### Help system

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
