#!perl -T

use strict;
use warnings;

BEGIN { $ENV{PERL_TEST_LEANER_USES_TEST_MORE} = 1 }

use Test::Leaner;

BEGIN {
 my $loaded;
 if ($INC{'Test/More.pm'}) {
  $loaded = 1;
 } else {
  $loaded = 0;
  require Test::More;
  Test::More->import;
 }
 Test::More::plan(tests => 1 + 4 * 15 + 3 * 3 + 2 * 8);
 Test::More::is($loaded, 1, 'Test::More has been loaded');
}

sub get_subroutine {
 my ($stash, $name) = @_;

 my $glob = $stash->{$name};
 return undef unless $glob;

 return *$glob{CODE};
}

my $leaner_stash = \%Test::Leaner::;
my $more_stash   = \%Test::More::;
my $this_stash   = \%main::;

my @exported = qw<
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

for (@exported) {
 my $more_variant     = get_subroutine($more_stash, $_);

 my $leaner_variant   = get_subroutine($leaner_stash, $_);
 Test::More::ok(defined $leaner_variant,
                                       "Test::Leaner variant of $_ is defined");
 my $imported_variant = get_subroutine($this_stash, $_);
 Test::More::ok(defined $imported_variant, "imported variant of $_ is defined");

 SKIP: {
  Test::More::skip('Need leaner and imported variants to be defined' => 2)
                   unless defined $leaner_variant
                      and defined $imported_variant;

  if (defined $more_variant) {
   Test::More::is($leaner_variant, $more_variant,
                  "Test::Leaner variant of $_ is Test::More variant");
   Test::More::is($imported_variant, $more_variant,
                  "imported variant of $_ is Test::More variant");
  } else {
   Test::More::is($imported_variant, $leaner_variant,
                  "imported variant of $_ is Test::Leaner variant");
   {
    local $@;
    eval { $leaner_variant->() };
    Test::More::like($@, qr/^\Q$_\E is not implemented.*at \Q$0\E line \d+/,
                         "Test::Leaner of $_ variant croaks");
   }
  }
 }
}

my @only_in_test_leaner = qw<
 tap_stream
 diag_stream
 THREADSAFE
>;

for (@only_in_test_leaner) {
 Test::More::ok(exists $leaner_stash->{$_},
                "$_ still exists in Test::Leaner");
 Test::More::ok(!exists $more_stash->{$_},
                "$_ was not imported into Test::More");
 Test::More::ok(!exists $this_stash->{$_},
                "$_ was not imported into main");
}

my @only_in_test_more = qw<
 use_ok
 require_ok
 can_ok
 isa_ok
 new_ok
 subtest
 explain
 todo_skip
>;

for (@only_in_test_more) {
 my $more_variant = get_subroutine($more_stash, $_);

 SKIP: {
  Test::More::skip("$_ is not implemented in this version of Test::More" => 2)
                   unless defined $more_variant;

  Test::More::ok(!exists $leaner_stash->{$_},
                 "$_ was not imported into Test::Leaner");
  Test::More::ok(!exists $this_stash->{$_},
                 "$_ was not imported into main");
 }
}
