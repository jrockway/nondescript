package Nondescript::Page::Subscription;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use Time::HiRes qw(time);

extends 'Tatsumaki::Handler';

__PACKAGE__->asynchronous(1);

use JSON::XS qw(encode_json decode_json);

has 'bus' => (
    is       => 'ro',
    isa      => 'Nondescript::Bus',
    required => 1,
);

sub get {
    my ($self, $key) = @_;

    $self->logger->debug("subscription page: subscribe to '$key'");

    $self->multipart_xhr_push(1);
    $self->bus->subscribe($key, $self->async_cb(sub {
        my ($key, $value) = @_;
        my $obj = decode_json($value);
        $obj->{access_time} = time;

        $self->stream_write($obj);
    }));
}

1;
