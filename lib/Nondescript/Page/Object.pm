package Nondescript::Page::Object;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use Time::HiRes qw(time);

extends 'Tatsumaki::Handler';

use JSON::XS qw(encode_json decode_json);

has 'bus' => (
    is       => 'ro',
    isa      => 'Nondescript::Bus',
    required => 1,
);

has 'cache' => (
    is       => 'ro',
    isa      => 'Nondescript::Cache',
    required => 1,
);

sub get {
    my ($self, $key) = @_;
    $self->logger->debug("object page: get '$key'");

    my $js = $self->cache->get($key) or
        die Tatsumaki::Error::HTTP->new(404, "No object named '$key'");

    my $obj = decode_json($js);
    $obj->{access_time} = time;

    $self->response->content_type('application/json');
    $self->write(encode_json($obj));
    $self->finish;
}

sub post {
    my ($self, @args) = @_;
    $self->put(@args);
}

sub put {
    my ($self, $key) = @_;
    my $data = $self->request->raw_body;

    $self->logger->debug("object page: post '$key' = '$data'");

    my $raw = 'unknown error';
    try {
        $raw = decode_json($data);
    } catch {
        $raw = $_;
    };

    $raw = 'not a dict' if ref $raw && ref $raw ne 'HASH';
    die Tatsumaki::Error::HTTP->new( 416, $raw ) if !ref $raw;

    $raw->{modify_time} = time;

    my $js = encode_json($raw);
    $self->bus->tell($key, $js);

    $self->logger->debug("object page: commit '$key' = '$js'");
    $self->write($js);
    $self->finish;
}

1;
