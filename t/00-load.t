#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

{
 package Test::Leaner::TestContainer;
 BEGIN {
  Test::More::use_ok( 'Test::Leaner' );
 }
}

diag( "Testing Test::Leaner $Test::Leaner::VERSION, Perl $], $^X" );
