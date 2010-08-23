use strict;
use warnings;
use FindBin qw($Bin);

use Plack::Builder;

use lib "$Bin/../lib";
use Nondescript;

my $app = Nondescript->new->app;

sub fix_path {
    my $_ = $_[0];
    return unless /[.](png|js|css|html)$/;
    return '/index.html' if $_ eq '/';

    m{/([^/]+)$} and return $1;
    return;
}

builder {
    enable 'Debug';
    enable 'Static', path => \&fix_path, root => "share/htdocs/";
    $app;
};
