#!perl -T

use strict;
use warnings;

use Test::Leaner tests => 4 + 1 + 2 + 1;

ok 1;
ok !!1,    'ok() test with a description';
ok 0.001,  'a float is fine too';
ok +{},    'a hash ref is fine too';

my @array = (undef);
ok @array, 'ok() forces scalar context';

my $ret = ok 1;
ok $ret, 'ok(true) returns true';

{
 package Test::Leaner::TestOverload::AlwaysFalse;

 use overload 'bool' => sub { 1 };

 sub new { bless { }, shift }
}

my $z = Test::Leaner::TestOverload::AlwaysFalse->new;

ok $z, 'ok($overloaded_true)';
