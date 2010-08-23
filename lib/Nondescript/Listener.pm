package Nondescript::Listener;
use Moose::Role;
use namespace::autoclean;

# has 'name' => (
#     is      => 'ro',
#     isa     => 'Str',
#     builder => '_build_name',
# );

requires 'recv';
#requires '_build_name';

1;
