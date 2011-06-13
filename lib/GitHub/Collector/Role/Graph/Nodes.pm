package GitHub::Collector::Role::Graph::Nodes;

use Moose::Role;

has nodes => (
    is         => 'rw',
    isa        => 'HashRef',
    lazy       => 1,
    default    => sub { {} },
    auto_deref => 1,
);

1;
