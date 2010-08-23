use strict;
use warnings;
use FindBin qw($Bin);

use Plack::Builder;

use lib "$Bin/../lib";
use Nondescript;

my $app = Nondescript->new->app;

builder {
    enable 'Debug';
    $app;
};
