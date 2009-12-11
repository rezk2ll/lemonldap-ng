package Lemonldap::NG::Manager;

use strict;
use Lemonldap::NG::Handler::CGI qw(:globalStorage :locationRules);
use Lemonldap::NG::Manager::Help;    #inherits

our $VERSION = '0.1';
our @ISA     = qw(
  Lemonldap::NG::Handler::CGI
  Lemonldap::NG::Manager::Downloader
  Lemonldap::NG::Manager::Uploader
  Lemonldap::NG::Manager::_Struct
  Lemonldap::NG::Manager::_i18n
);

BEGIN {
    *process = *doall;
}

sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new($args)
      or $class->abort( 'Unable to start ' . __PACKAGE__,
        'See Apache logs for more' );
    if ( $ENV{PATH_INFO} eq "/css" ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME}, -type => 'text/css',
        );
        $self->css;
        $self->quit();
    }
    elsif ( $ENV{PATH_INFO} eq "/js" ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME},
            -type => 'text/javascript', );
        $self->js;
        $self->quit();
    }
    elsif ( $self->param('help') ) {
        print $self->header_public( $ENV{SCRIPT_FILENAME},
            -type => 'text/html; charset=utf8' );
        Lemonldap::NG::Manager::Help::import( $self->{language}
              || $ENV{HTTP_ACCEPT_LANGUAGE} )
          unless ( $self->can('help_groups') );
        my $chap = $self->param('help');
        eval { no strict "refs"; &{"help_$chap"} };
        $self->quit();
    }
    elsif ( my $rdata = $self->rparam('data') ) {

        require Lemonldap::NG::Manager::Uploader;    #inherits
        $self->confUpload($rdata);
        $self->quit();
    }
    require Lemonldap::NG::Manager::Downloader;      #inherits
    $self->{cfgNum} =
         $self->param('cfgNum')
      || $self->confObj->lastCfg()
      || 'UNAVAILABLE';
    if ( my $p = $self->param('node') ) {
        print $self->header( -type => 'text/html; charset=utf8', );
        print $self->node($p);
        $self->quit();
    }
    return $self;
}

sub menu {
    my $self = shift;
    require Lemonldap::NG::Manager::Downloader;    #inherits
    return
        '<ul class="simpleTree">' 
      . $self->li( 'root', 'root' )
      . $self->span( 'root', "Configuration $self->{cfgNum}",
        $self->{cfgNum}, 'none' )
      . '<ul>'
      . $self->node()
      . '</ul></li></ul>';
}

1;
