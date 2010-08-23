package Nondescript::Bus;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw(HashRef CodeRef);
use MooseX::Types::Set::Object;

with 'MooseX::LogDispatch';

use Coro;
use Try::Tiny;

has 'internal_listeners' => (
    init_arg   => undef,
    is         => 'ro',
    isa        => 'Set::Object',
    handles    => { unsubscribe_internal => 'delete' },
    lazy_build => 1,
);

sub _build_internal_listeners {
    my $s = Set::Object->new;
    return $s;
}

sub subscribe_internal {
    my ($self, $listener) = @_;
    confess "listener $listener cannot do 'Nondescript::Listener'"
        unless $listener->does('Nondescript::Listener');

    $self->logger->debug("bus: subscribing internal listener $listener");
    $self->internal_listeners->insert($listener);

    return;
}

has 'listeners' => (
    is      => 'ro',
    traits  => ['Hash'],
    isa     => HashRef['Set::Object'],
    default => sub { +{} },
    handles => {
        _add_listener_set => 'set',
        watched_keys      => 'keys',
    },
);

sub subscribe {
    my ($self, $key, $listener) = @_;
    confess 'listener must be a coderef accepting ($k, $v) pairs'
        unless ref $listener && ref $listener eq 'CODE';

    $self->logger->debug("bus: subscribing '$key' listener $listener");

    my $listener_set = ($self->listeners->{$key} ||= Set::Object->new);
    $listener_set->insert($listener);

    return;
}

sub unsubscribe {
    my ($self, $key, $listener) = @_;

    $self->logger->debug("bus: unsubscribing '$key' listener $listener");

    my $listener_set = ($self->listeners->{$key} ||= Set::Object->new);
    $listener_set->delete($listener);

    return;
}

# TODO: 'queue-depth == 1' behavior
sub tell {
    my ($self, $k, $v) = @_;

    $self->logger->debug("bus: tell '$k': '$v'");

    for my $internal ($self->internal_listeners->members) {
        #async {
            $internal->recv($k, $v);
        #};
    }

    my $listener_set = ($self->listeners->{$k} ||= Set::Object->new);

    for my $listener ($listener_set->members) {
        #async {
            $listener->($k, $v)
        #};
    }

    return;
}

1;
