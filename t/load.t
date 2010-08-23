use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Nondescript' }

my $n = Nondescript->new;
isa_ok $n, 'Nondescript';

isa_ok $n->app, 'Tatsumaki::Application';

done_testing;
