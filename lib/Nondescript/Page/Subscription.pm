package Nondescript::Page::Subscription;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use Time::HiRes qw(time);

extends 'Tatsumaki::Handler';
with 'MooseX::LogDispatch', 'MooseX::Clone';

use JSON::XS qw(encode_json decode_json);

has 'bus' => (
    is       => 'ro',
    isa      => 'Nondescript::Bus',
    required => 1,
);

sub get {
}

sub put {
}

1;
