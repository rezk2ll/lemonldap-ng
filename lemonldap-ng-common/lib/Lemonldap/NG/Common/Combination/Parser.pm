package Lemonldap::NG::Common::Combination::Parser;

use strict;
use Mouse;
use Safe;
use constant PE_OK => 0;

# Handle "if then else" (used during init)
# return a sub that can be called with ($req) to get a [array] of combination
#
# During auth, these combinations represents "or" (like Multi)
# Each combination is a [authSub,userSub] called like this:
#      $authSub->('authenticate',$req)
# This means that the 'authenticate' method of the real auth module will be
# called with $req

sub parse {
    my ( $self, $moduleList, $expr ) = @_;

    my $sub  = '';
    my $rest = $expr;
    if ( $rest =~ s/^\s*if\s*\(// ) {
        my ( $cond, $then, $else );
        ( $cond, $rest ) = $self->findB( $rest, ')' );
        unless ($cond) {
            die('Bad combination: unmatched bracket');
        }
        unless ( $rest =~ s/\s*then\s*\{// ) {
            die('Bad combination: missing "then"');
        }
        ( $then, $rest ) = $self->findB( $rest, '}' );
        unless ($then) {
            die('Bad combination: missing "then" content');
        }
        unless ( $rest =~ s/\s*else\s*\{// ) {
            die('Bad combination: missing "else"');
        }
        ( $else, $rest ) = $self->findB( $rest, '}' );
        unless ($else) {
            die('Bad combination: missing "else" content');
        }
        if ( $rest !~ /^\s*$/ ) {
            die('Bad combination: trailing characters after else{}');
        }

        $cond = buildSub($cond);
        $then = $self->parse( $moduleList, $then );
        $else = $self->parse( $moduleList, $else );
        unless ( $then and $else ) {
            die('Bad combination: bad then or else');
        }
        return sub {
            my ( $sub, $req ) = @_;
            return [
                ( $cond->($req) ? $then->[0]->($@) : $else->[0]->($@) ),
                ( $cond->($req) ? $then->[1]->($@) : $else->[1]->($@) ),
            ];
        };
    }
    else {
        my $res = $self->parseOr( $moduleList, $rest );
        return sub { $res };
    }
}

# Internal request to manage "or" boolean expr.
# Returns [ [authSub,userSub], [authSub,userSub] ] array
sub parseOr {
    my ( $self, $moduleList, $expr ) = @_;
    my @res;
    foreach my $part ( split /\s+or\s+/, $expr ) {
        push @res, $self->parseAnd( $moduleList, $part );
    }
    return \@res;
}

# Internal request to manage "and" boolean expr
# Returns [authSub,userSub] array
sub parseAnd {
    my ( $self, $moduleList, $expr ) = @_;
    if ( $expr =~ /\]\s*and\s*\[/ ) {
        my @mod = ( [], [] );
        foreach my $part ( split /\]\s*and\s*\[/, $expr ) {
            my $tmp = $self->parseBlock( $moduleList, $part );
            push @{ $mod[0] }, $tmp->[0];
            push @{ $mod[1] }, $tmp->[1];
        }
        my @res;
        foreach my $type (@mod) {
            push @res, sub {
                foreach my $obj (@$type) {
                    my $r = $obj->(@_);
                    return $r unless ( $r == PE_OK );
                }
                return PE_OK;
            };
        }
        return \@res;
    }
    else {
        return $self->parseBlock( $moduleList, $expr );
    }
}

# Internal method to parse [AuthModule,UserModule] expr
# Returns [authSub,userSub] array
sub parseBlock {
    my ( $self, $moduleList, $expr ) = @_;
    unless ( $expr =~ /^\s*\[(.*?)\s*(?:,\s*(.*?))?\s*\]\s*$/ ) {
        die "Bad expression: $expr";
    }
    my @res = ( $1, $2 || $1 );
    @res = map { $self->parseMod( $moduleList, $_ ) } @res;
    return \@res;
}

# Internal method to parse auth or userDB expr
# These expressions can be "LDAP" or "LDAP and DBI"
# Return sub
sub parseMod {
    my ( $self, $moduleList, $expr ) = @_;
    my @mods = map {
        die "Unknown module $_"
          unless ( $moduleList->{$_} );
        $moduleList->{$_}
    } split( /\s+and\s+/, $expr );
    if ( @mods == 1 ) {
        my ($m) = @mods;
        return sub {
            my ( $sub, $req ) = @_;
            return $m->$sub($req);
        };
    }
    return sub {
        my ( $sub, $req ) = @_;
        foreach my $obj (@mods) {
            my $res = $obj->$sub($req);
            return $res unless ( $res == PE_OK );
        }
        return PE_OK;
    };
}

# Internal request to find brackets
sub findB {
    my ( $self, $expr, $char ) = @_;
    my $res;
    my @chars = split //, $expr;
    while ( my $c = shift @chars ) {
        if ( $c eq "\\" ) {
            $res .= $c . shift(@chars);
            next;
        }
        if ( $c eq $char ) {
            my $rest = join( '', @chars );
            $res =~ s/^\s*(.*?)\s*/$1/;
            $rest =~ s/^\s*(.*?)\s*/$1/;
            return ( $res, $rest );
        }
        if ( $c =~ /^(?:\(|\{|\[|'|")$/ ) {
            my $wanted = {
                '(' => ')',
                '{' => '}',
                '[' => ']',
                "'" => "'",
                '"' => '"'
            }->{$c};
            my ( $m, $rest ) =
              $self->findB( join( '', @chars ), $wanted );
            unless ($m) {
                die("Bad combination: unmatched $c");
            }
            $res .= "$c$m$wanted";
            @chars = split //, $rest;
            next;
        }
        $res .= $c;
    }
    return undef;
}

# Compiles condition into sub
sub buildSub {
    my ( $self, $cond ) = @_;
    my $safe = Safe->new;
    my $res  = $safe->reval("sub{my(\$req)=@\_;return ($cond)}");
    die "Bad condition $cond: $@" if ($@);
    return $res;
}

1;
