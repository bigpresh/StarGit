package GitHub::Collector::Role::Graph::Edges;

use Moose::Role;

has edges => (
    is         => 'rw',
    isa        => 'HashRef',
    lazy       => 1,
    default    => sub { {} },
    auto_deref => 1,
);

1;
