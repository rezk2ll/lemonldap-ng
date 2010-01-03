## @file
# Lemonldap::NG manager main file

## @class
# Lemonldap::NG manager main class
package Lemonldap::NG::Manager;

use strict;
use Lemonldap::NG::Handler::CGI qw(:globalStorage :locationRules);    #inherits
use Lemonldap::NG::Manager::Help;                                     #inherits

our $VERSION = '0.93';
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

## @cmethod Lemonldap::NG::Manager new(hashRef args)
# Class constructor.
#@param args hash reference
#@return Lemonldap::NG::Manager object
sub new {
    my ( $class, $args ) = @_;
    my $self = $class->SUPER::new($args)
      or $class->abort( 'Unable to start ' . __PACKAGE__,
        'See Apache logs for more' );
    if ( $self->param('help') ) {
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
    if ( $self->param('cfgAttr') ) {
        $self->sendCfgParams( $self->conf );
    }
    return $self;
}

## @method string menu()
# Build the tree menu.
# @return HTML string
sub menu {
    my $self = shift;
    require Lemonldap::NG::Manager::Downloader;
    return
        '<ul class="simpleTree">' 
      . $self->li( 'root', 'root' )
      . $self->span( 'root', "Configuration $self->{cfgNum}",
        $self->{cfgNum}, 'cfgDatas', 'default' )
      . '<ul>'
      . $self->node()
      . '</ul></li></ul>';
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Manager - Perl extension for managing Lemonldap::NG Web-SSO
system.

=head1 SYNOPSIS

See example/Index.pl

=head1 DESCRIPTION

Lemonldap::NG::Manager provides a web interface to manage Lemonldap::NG Web-SSO
system.

=head1 SEE ALSO

L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>, L<CGI>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2009 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
