package Graph::GEXF::Role::Viz::Position;

use Moose::Role;

my $_has_position = 0;

has [qw/x y z/] => (
    is      => 'rw',
    isa     => 'Num',
    trigger => sub { $_has_position++ },
    traits  => ['Chained'],
);

sub has_position { $_has_position }

no Moose::Role;

1;
