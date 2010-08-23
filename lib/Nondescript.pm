# ABSTRACT: streaming publish/subscribe over HTTP
package Nondescript;
use strict;
use warnings;

use Moose;
use Bread::Board;

with 'MooseX::LogDispatch';

use Tatsumaki::Application;
use Nondescript::Page::Index;

use namespace::autoclean;

has 'breadboard' => (
    is      => 'ro',
    isa     => 'Bread::Board::Container',
    handles => ['fetch'],
    builder => '_build_breadboard',
);

sub _build_breadboard {
    my $self = shift;

    return container 'Nondescript' => as {
        service 'logger' => (
            block => sub { $self->logger },
        );

        service 'database' => (
            block => sub { () },
        );

        service 'cache' => (
            block => sub { () },
        );

        service 'bus' => (
            block => sub { () },
        );

        container 'pages' => as {
            service 'index' => (
                lifecycle    => 'Singleton',
                class        => 'Nondescript::Page::Index',
                dependencies => {
                    logger => depends_on('/logger'),
                },
            );
        };

        service 'app' => (
            dependencies => {
                index_page => depends_on('/pages/index'),
            },
            block => sub {
                my $b = shift;
                return Tatsumaki::Application->new([
                    '/' => $b->get_dependency('index_page')->get,
                ]);
            },
        );
    };
}

sub app {
    my $self = shift;
    return $self->fetch('app')->get;
}

1;
