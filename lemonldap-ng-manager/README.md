# angular-lemonldap-ng-manager

This is just a POC to build an angular based manager for
Lemonldap::NG.

See [LemonLDAP::NG website](http://lemonldap-ng.org/).

## Install

    git clone https://github.com/guimard/angular-lemonldap-ng-manager.git
    cd angular-lemonldap-ng-manager
    npm install

## Start servers

    npm run perlserver
    npm start

## MVC

* The view is managed by :
  * `index.html` for HTML building
  * _some other html files for forms ?_
  * `struct.json` who gives the tree position for each configuration element and
    requests to do
  * translate.json (which will be delivered by a CGI to choose current language)
* The controller is splitted in 2 pieces :
  * client side in `js/manager.js`, based on ANgularJS, it provides the link
    between the DOM and the CGI. It manages:
    * downloads of JSON datas
    * translations
    * form display depending on data types
  * server side, based on PSGI, it provides the link between network and
    configuration. It will be able to respond to 3 types of _rest_ queries:
    * key values
    * hash keys for this type of nodes
    * hash content
* The model (datas) is:
  * the current configuration
  * the modified datas _(client side only or both to be able to notify changes
    to other administrators ?)_

