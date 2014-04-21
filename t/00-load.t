#!perl -T
use 5.10.1;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'App::Game::Memory' ) || print "Bail out!\n";
}

diag( "Testing App::Game::Memory $App::Game::Memory::VERSION, Perl $], $^X" );
