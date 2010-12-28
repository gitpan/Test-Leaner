#!perl -T

use strict;
use warnings;

use Test::Leaner tests => 7;

pass 'test begin';

SKIP: {
 skip 'test skipping a block' => 1;
 fail 'should not be reached';
}

SKIP: {
 pass 'outer block begin';
 SKIP: {
  skip 'test skipping the inner nested block' => 1;
  fail 'should not be reached either';
 }
 pass 'back to outer block';
 skip 'test skipping the outer nested block' => 1;
 fail 'should not be reached as well';
}

pass 'test end';
