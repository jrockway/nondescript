package Nondescript::Cache;
use Moose;
use namespace::autoclean;

with 'Nondescript::Listener', 'MooseX::LogDispatch';

has 'cache' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { +{} },
);

sub get {
    my ($self, $k) = @_;
    my $v = $self->cache->{$k};
    $self->logger->debug("cache: get '$k' (= '$v')");
    return $v;
}

sub set {
    my ($self, $k, $v) = @_;
    $self->logger->debug("cache: set '$k' = '$v'");
    $self->cache->{$k} = $v;
    return;
}

sub recv {
    my ($self, $k, $v) = @_;
    $self->set($k, $v);
    return;
}

1;
