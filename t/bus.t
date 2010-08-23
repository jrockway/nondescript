use strict;
use warnings;
use Test::More;

use AnyEvent;
use Coro;

use Nondescript::Bus;

my $bus = Nondescript::Bus->new;
my $done = AnyEvent->condvar;

$done->begin;
$done->begin;
$done->begin;

my ($foo, $bar, $foo_count, $bar_count);

my $FOO = sub { $foo = [@_]; $foo_count++; $done->end };
my $BAR = sub { $bar = [@_]; $bar_count++; $done->end };

$bus->subscribe('foo', $FOO);
$bus->subscribe('bar', $BAR);

$bus->tell('foo', 'FOO');
$bus->tell('a_boring_story', 'when i was your age, ...');
$bus->tell('bar', 'wrong bar');
$bus->unsubscribe('foo', $FOO);
$bus->tell('foo', 'wrong foo');
$bus->tell('bar', 'BAR');

$done->recv;

is $foo_count, 1, 'foo unsubscribed early';
is $bar_count, 2, 'got bar count';
is_deeply $foo, ['foo', 'FOO'], 'got foo';
is_deeply $bar, ['bar', 'BAR'], 'got bar';

done_testing;
