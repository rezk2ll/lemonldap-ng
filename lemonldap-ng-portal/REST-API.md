# Lemonldap::NG::Portal REST API

* protect some entry points by vhost access rules ?
  Yes: the portal will be an
  handler (will inherit from `Handler::PSGI::Router`) but instead of rejecting
  unauthenticated users, it will call an other function tree _(**NB**: `undef`
  means same name in Common::PSGI::Router)_:

        # REST paths for authenticated users
        $self->addRoute( 'menu.html' => undef, ['GET'] )
             ->addRoute( 'applications' => undef, ['GET'] ),
             ->addRoute( 'accounts' => { ':id' => 'account' }, ['GET','POST'] ),
             ->addRoute( 'accounts' => { '*' => 'accounts' }, ['GET','POST'] );
        $self->defaultRoute( 'menu.html' );
    
        # REST paths for unauthenticated users
        $self->addUnauthRoute( 'auth.html', undef, ['GET'] )
             ->addUnauthRoute( 'auth' => 'authenticate', ['POST'] );
        $self->defaultUnauthRoute( 'auth.html' );

        # Part of API protected by web server
        $self->addUnauthRoute( 'sessions' => { ':sessionId' => 'session' }, ['GET', 'POST', 'PUT'] )
             ->addUnauthRoute( 'sessions' => { '*' => 'sessions', ['GET', 'POST'] );

## Authentication

### Authentication with web form

Depending on the request:
* case classic POST: `POST /auth`, datas : `user=xx&password=yy`, HTML
  response
* case Ajax request: same but response is JSON (menu entries ?). The idea is
  that a full Ajax portal could be written with some HTML fragment storable in
  cache (like manager forms). So only a few Ajax requests will be sent through
  the network

## Menu

Menu will be full Ajax:
* `GET /` will be an alias for `GET /menu.html`. This page will not be
  protected but all Ajax request will be (and if session is invalid, redirection
  to `/`
* `GET /applications` will return a JSON file containing available applications
  for current user

## Sessions

* Session content: `GET /sessions/<sessionId>`
* New session: `POST /sessions`
* Update session: `PUT /sessions/<sessionId>` with fields to changes

## Accounts

* Create account: `POST /accounts`, post datas: _\<attribute names with values>_
* Validate account: `GET /accounts/<whatToTrace-field>?validate`
* Show account: `GET /account/<whatToTrace-field>`
* List accounts: `GET /accounts`, returns list of _`whatToTrace`_ values

Examples:

* `POST /accounts`
* `GET /accounts/dhwo@badwolf.org?validate`
* `GET /accounts/dhwo@badwolf.org`
* `GET /accounts`


### Passwords

* Initialize password change (sends a mail to user): `POST /accounts/<whatToTrace-field>?passwordInit`
* Finalize password change (sends a mail to user): `POST /accounts/<whatToTrace-field>?validatePassword`
* Force password change enve if not initialized (sends a mail to user):
  `PUT /accounts/<whatToTrace-field>?validatePassword&force`, data: password=_newValue_

## Other

* Ping (session already available): `GET or POST /?ping`, response `{result: true}`
* 
