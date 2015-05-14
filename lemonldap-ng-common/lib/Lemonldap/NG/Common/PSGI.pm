package Lemonldap::NG::Common::PSGI;

use 5.10.0;
use Mouse;
use JSON;
use Lemonldap::NG::Common::PSGI::Constants;
use Lemonldap::NG::Common::PSGI::Request;

our $VERSION = '2.0.0';

our $_json = JSON->new->allow_nonref;

has error        => ( is => 'rw', default => '' );
has languages    => ( is => 'rw', isa     => 'Str', default => 'en' );
has logLevel     => ( is => 'rw', isa     => 'Str' );
has staticPrefix => ( is => 'rw', isa     => 'Str' );
has templateDir  => ( is => 'rw', isa     => 'Str' );
has links        => ( is => 'rw', isa     => 'ArrayRef' );

sub lmLog {
    my ( $self, $msg, $level ) = splice @_;
    my $levels = {
        emerg  => 7,
        alert  => 6,
        crit   => 5,
        error  => 4,
        warn   => 3,
        notice => 2,
        info   => 1,
        debug  => 0
    };
    my $l = $levels->{$level} || 1;
    return if ( ref($self) and $l < $levels->{ $self->{logLevel} } );
    print STDERR "[$level] " . ( $l ? '' : (caller)[0] . ': ' ) . " $msg\n";
}

# Responses methods
sub sendJSONresponse {
    my ( $self, $req, $j, %args ) = splice @_;
    $args{code} ||= 200;
    my $type = 'text/json';
    if ( ref $j ) {
        if ( $args{forceJSON} or $req->accept =~ m|application/json| ) {
            $j = $_json->encode($j);
        }
        else {

            # TODO: escape keys in hash values
            eval {
                require XML::Simple;
                $j    = XML::Simple::XMLout($j);
                $type = 'text/xml';
            };
        }
    }
    return [ $args{code}, [ 'Content-Type', $type ], [$j] ];
}

sub sendError {
    my ( $self, $req, $err, $code ) = splice @_;
    $err  ||= $req->error;
    $code ||= 500;
    return $self->sendJSONresponse( $req, { error => $err }, code => $code );
}

sub abort {
    my ( $self, $err ) = splice @_;
    $self->lmLog( $err, 'error' );
    return sub {
        $self->sendError( Lemonldap::NG::Common::PSGI::Request->new( $_[0] ),
            $err, 500 );
    };
}

sub _mustBeDefined {
    my $name = ( caller(1) )[3];
    $name =~ s/^.*:://;
    my $call = ( caller(1) )[0];
    my $ref = ref( $_[0] ) || $call;
    die "$name() method must be implemented (probably in $ref)";
}

sub init { 1 }

sub router { _mustBeDefined(@_) }

sub sendHtml {
    my ( $self, $req, $template ) = splice @_;
    my $htpl;
    $template = $self->templateDir . "$template.tpl";
    return $self->sendError( $req, "Unable to read $template", 500 )
      unless ( -r $template and -f $template );
    eval {
        $self->lmLog( "Starting HTML generation using $template", 'debug' );
        require HTML::Template;
        $htpl = HTML::Template->new(
            filehandle             => IO::File->new($template),
            path                   => $self->templateDir,
            die_on_bad_params      => 1,
            die_on_missing_include => 1,
            cache                  => 0,
        );

        # TODO: replace app
        # TODO: warn if STATICPREFIX does not end with '/'
        my $sp = $self->staticPrefix;
        $sp =~ s/\/*$/\//;
        $htpl->param(
            SCRIPT_NAME         => $req->scriptname,
            STATIC_PREFIX       => $sp,
            AVAILABLE_LANGUAGES => $self->languages,
            LINKS => $self->links ? encode_json( $self->links ) : '""',
        );
    };
    if ($@) {
        return $self->sendError( $req, "Unable to load template: $@", 500 );
    }
    $self->lmLog(
        'For more performance, store the result of this as static file',
        'info' );

    # Set headers
    my $hdrs = [ 'Content-Type' => 'text/html' ];
    unless ( $self->logLevel eq 'debug' ) {
        push @$hdrs,
          ETag            => "LMNG-manager-$VERSION",
          'Cache-Control' => 'private, max-age=2592000';
    }
    $self->lmLog( "Sending $template", 'debug' );
    return [ 200, $hdrs, [ $htpl->output() ] ];
}

###############
# Main method #
###############

sub run {
    my ( $self, $args ) = splice @_;
    $self = $self->new($args) unless ref($self);
    return $self->abort( $self->error ) unless ( $self->init($args) );
    return $self->_run;
}

sub _run {
    my $self = shift;
    return sub {
        $self->router( Lemonldap::NG::Common::PSGI::Request->new( $_[0] ) );
    };
}

1;
