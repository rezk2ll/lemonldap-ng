# Methods run at server startup / reload

package Lemonldap::NG::Handler::Initialization::LocalInit;

use Lemonldap::NG::Handler::SharedConf;    # Needed to get VERSION
use Lemonldap::NG::Handler::Main::Logger;
use Lemonldap::NG::Handler::API qw(:httpCodes);

our $VERSION = '1.4.0';
my ( $statusPipe, $statusOut );

## @imethod void localInit(hashRef args)
# Launch the status process (statusProcess()) if wanted
# @param $args reference to the initialization hash
sub localInit($$) {
    my ( $class, $args ) = splice @_;

    $class->statusInit if ($args->{status});
    $class->serverSignatureInit unless ($args->{hideSignature});

    return ( $statusPipe, $statusOut );
}

sub serverSignatureInit {
    my $class = shift;
    Lemonldap::NG::Handler::API->setServerSignature(
        "Lemonldap::NG::Handler/" . $Lemonldap::NG::Handler::VERSION
    ) if ( $Lemonldap::NG::Handler::VERSION );
}


## @ifn protected void statusInit()
# Launch the status process
sub statusInit {
    my $class = shift;
    require IO::Pipe;
    $statusPipe = IO::Pipe->new;
    $statusOut  = IO::Pipe->new;
    if ( my $pid = fork() ) {
        $statusPipe->writer();
        $statusOut->reader();
        $statusPipe->autoflush(1);
    }
    else {
        $statusPipe->reader();
        $statusOut->writer();
        my $fdin  = $statusPipe->fileno;
        my $fdout = $statusOut->fileno;
        open STDIN,  "<&$fdin";
        open STDOUT, ">&$fdout";
        my @tmp = ();
        push @tmp, "-I$_" foreach (@INC);
        exec 'perl', '-MLemonldap::NG::Handler::Status',
          @tmp,
          '-e',
          "&Lemonldap::NG::Handler::Status::run()";
    }
}

1;
