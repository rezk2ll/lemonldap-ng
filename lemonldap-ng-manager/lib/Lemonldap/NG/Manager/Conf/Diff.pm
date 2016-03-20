package Lemonldap::NG::Manager::Conf::Diff;

use strict;
use Mouse;
use Lemonldap::NG::Manager::Conf::Parser;

*defaultValue = \&Lemonldap::NG::Manager::Conf::Parser::defaultValue;

sub diff {
    my ( $self, @conf ) = @_;
    my @res;
    my @keys = ( [ keys %{ $conf[0] } ], [ keys %{ $conf[1] } ] );
    while ( my $key = shift @{ $keys[0] } ) {

        # TODO
        next if ( $key eq 'applicationList' );
        if ( ref $conf[0]->{$key} eq 'HASH' ) {
            if ( ref $conf[1]->{$key} ) {
                my @tmp = $self->diff( $conf[0]->{$key}, $conf[1]->{$key}, 1 );
                for ( my $i = 0 ; $i < @tmp ; $i++ ) {
                    $res[$i]->{$key} = $tmp[$i] if ( $tmp[$i] );
                }
            }
            else {
                $res[0]->{$key} = $conf[0]->{$key};
            }
        }
        elsif ( ref $conf[0]->{$key} eq 'ARRAY' ) {
            die 'TODO';
        }
        elsif ( exists $conf[1]->{$key} ) {
            if ( $conf[0]->{$key} ne $conf[1]->{$key} ) {
                $res[0]->{$key} = $conf[0]->{$key};
                $res[1]->{$key} = $conf[1]->{$key};
            }
        }
        elsif ( $conf[2] or $conf[0]->{$key} ne $self->defaultValue($key) ) {
            $res[0]->{$key} = $conf[0]->{$key};
        }
        $keys[1] = [ grep { $_ ne $key } @{ $keys[1] } ];
    }
    while ( my $key = shift @{ $keys[1] } ) {

        # TODO
        next if ( $key eq 'applicationList' );
        if (
            (
                not ref( $conf[1]->{$key} )
                and
                ( $conf[2] or $conf[1]->{$key} ne $self->defaultValue($key) )
            )
            or ( ref( $conf[1]->{$key} ) eq 'HASH' and %{ $conf[1]->{$key} } )
          )
        {
            $res[1]->{$key} = $conf[1]->{$key};
        }
    }
    return @res;
}

1;
