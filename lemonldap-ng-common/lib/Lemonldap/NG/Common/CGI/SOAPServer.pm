## @file
# SOAP support for Lemonldap::NG::Common::CGI

## @class
# Extend SOAP::Transport::HTTP::Server to be able to use posted datas catched
# by CGI module.
# All Lemonldap::NG cgi inherits from CGI so with this library, they can
# understand both browser and SOAP requests.
package Lemonldap::NG::Common::CGI::SOAPServer;
use SOAP::Transport::HTTP;
use base qw(SOAP::Transport::HTTP::Server);
use bytes;

our $VERSION = '2.0.0';

## @method protected void DESTROY()
# Call SOAP::Trace::objects().
sub DESTROY { SOAP::Trace::objects('()') }

## @cmethod Lemonldap::NG::Common::CGI::SOAPServer new(@param)
# @param @param SOAP::Transport::HTTP::Server::new() parameters
# @return Lemonldap::NG::Common::CGI::SOAPServer object
sub new {
    my $self = shift;
    return $self if ref $self;

    my $class = ref($self) || $self;
    $self = $class->SUPER::new(@_);
    SOAP::Trace::objects('()');

    return $self;
}

## @method void handle(CGI cgi)
# Build SOAP request using CGI->param('POSTDATA') and call
# SOAP::Transport::HTTP::Server::handle() then return the result to the client.
# @param $cgi CGI object
sub handle {
    my $self = shift->new;
    my $cgi  = shift;

    my $content = $cgi->param('POSTDATA');
    my $length  = bytes::length($content);

    if ( !$length ) {
        $self->response( HTTP::Response->new(411) )    # LENGTH REQUIRED
    }
    elsif ( defined $SOAP::Constants::MAX_CONTENT_SIZE
        && $length > $SOAP::Constants::MAX_CONTENT_SIZE )
    {
        $self->response( HTTP::Response->new(413) )   # REQUEST ENTITY TOO LARGE
    }
    else {
        $self->request(
            HTTP::Request->new(
                'POST' => $ENV{'SCRIPT_NAME'},
                HTTP::Headers->new(
                    map {
                        (
                              /^HTTP_(.+)/i
                            ? ( $1 =~ m/SOAPACTION/ )
                                  ? ('SOAPAction')
                                  : ($1)
                            : $_
                          ) => $ENV{$_}
                    } keys %ENV
                ),
                $content,
            )
        );
        $self->SUPER::handle();
    }

    print $cgi->header(
        -status => $self->response->code . " "
          . HTTP::Status::status_message( $self->response->code ),
        -type           => $self->response->header('Content-Type'),
        -Content_Length => $self->response->header('Content-Length'),
        -SOAPServer     => 'Lemonldap::NG CGI',
    );
    binmode( STDOUT, ":bytes" );
    print $self->response->content;
}

1;
