package Nondescript::Page::Index;
use Moose;
use namespace::autoclean;

extends 'Tatsumaki::Handler';

#__PACKAGE__->asynchronous(1);

has 'message' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'world',
);

sub get {
    my $self = shift;
    $self->write("Hello, ". $self->message. ".");
}

1;
