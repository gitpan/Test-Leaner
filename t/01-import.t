#!perl -T

use strict;
use warnings;

use Test::More ();

BEGIN {
 delete $ENV{PERL_TEST_LEANER_USES_TEST_MORE};
 *tm_is = \&Test::More::is;
}

Test::More::plan(tests => 2 * 15);

require Test::Leaner;

my @syms = qw<
 plan
 skip
 done_testing
 pass
 fail
 ok
 is
 isnt
 like
 unlike
 cmp_ok
 is_deeply
 diag
 note
 BAIL_OUT
>;

for (@syms) {
 eval { Test::Leaner->import(import => [ $_ ]) };
 tm_is $@,            '',                          "import $_";
 tm_is prototype($_), prototype("Test::More::$_"), "prototype $_";
}
