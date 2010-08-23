# ABSTRACT: streaming publish/subscribe over HTTP
package Nondescript;
use strict;
use warnings;

use Moose;
use Bread::Board;

with 'MooseX::LogDispatch';

use namespace::autoclean;

has 'breadboard' => (
    is      => 'ro',
    isa     => 'Bread::Board::Container',
    handles => ['fetch'],
    builder => '_build_breadboard',
);

sub _build_breadboard {
    my $self = shift;

    my $board; $board = container 'Nondescript' => as {
        service 'breadboard' => (
            lifecycle => 'Singleton',
            block     => sub { $board },
        );

        service 'logger' => (
            lifecycle => 'Singleton',
            block     => sub { $self->logger },
        );

        service 'cache' => (
            lifecycle    => 'Singleton',
            class        => 'Nondescript::Cache',
            dependencies => {
                logger => depends_on('/logger'),
            },
        );

        service 'bus' => (
            lifecycle    => 'Singleton',
            class        => 'Nondescript::Bus',
            dependencies => {
                logger => depends_on('/logger'),
                cache  => depends_on('/cache'),
            },

            block => sub {
                my $b = shift;
                my $bus = $b->class->new(
                    logger => $b->get_dependency('logger')->get,
                );
                $bus->subscribe_internal($b->get_dependency('cache')->get);
                return $bus;
            },
        );

        container 'pages' => as {
            service 'index' => (
                lifecycle    => 'Singleton',
                class        => 'Nondescript::Page::Index',
                dependencies => {
                    logger => depends_on('/logger'),
                },
            );

            service 'objects' => (
                class        => 'Nondescript::Page::Object',
                dependencies => {
                    logger => depends_on('/logger'),
                    bus    => depends_on('/bus'),
                    cache  => depends_on('/cache'),
                },
            );

            service 'subscription' => (
                class        => 'Nondescript::Page::Subscription',
                dependencies => {
                    logger => depends_on('/logger'),
                    bus    => depends_on('/bus'),
                },
            );
        };

        service 'handlers' => [
            '/objects/([^/]+)'       => 'pages/objects',
            '/subscriptions/([^/]+)' => 'pages/subscription',
            '/'                      => 'pages/index',
        ];

        service 'app' => (
            type         => 'Setter',
            class        => 'Tatsumaki::Application',
            dependencies => {
                'breadboard'   => depends_on('/breadboard'),
                'add_handlers' => depends_on('/handlers'),
            },
        );
    };

    return $board;
}

sub app {
    my $self = shift;
    return $self->fetch('app')->get;
}

1;
