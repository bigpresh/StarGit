package Graph::GEXF::Role::Viz::Size;

use MooseX::Role::Parameterized;

parameter as => (
    is       => 'ro',
    required => 1,
);

role {
    my $p = shift;

    has $p->as => (
        is      => 'rw',
        isa     => 'Num',
        default => '1.0',
        traits  => ['Chained'],
    );
};

1;
