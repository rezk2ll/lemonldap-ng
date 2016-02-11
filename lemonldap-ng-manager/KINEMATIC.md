# Lemonldap::NG::Manager kinematic

## Initialization

    PSGI file
     |
     +-> Common::PSGI::run() (Manager inheritance)
          |
          +-> Common::PSGI::new() unless(defined $self)
          |
          +-> Manager::init()
               |
               +-> Manager::<modules>::addRoutes()
                   (module can be one of `Conf`, `Sessions`, `Notifications`
                    |
                    +-> Common::PSGI::Router::addRoute()
           
_Common::PSGI::run()_ returns a subroutine

## HTTP responses

PSGI system launch the previous sub

    sub
     |
     +-> Common::PSGI::Router::handler ( Lemonldap::NG::Common::PSGI::Request->new() )
          |
          +-> Common::PSGI::Router::followPath()
               |
               +-> Launch the corresponding Manager::<module> subroutine declared with addRoutes()

