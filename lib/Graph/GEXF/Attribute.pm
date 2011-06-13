package Graph::GEXF::Attribute;

use Moose;

has id => (is => 'ro', isa => 'Int', required => 1,);
has title => (is => 'rw', isa => 'Str');
has value => (is => 'rw', isa => 'Str');
has type  => (
    is  => 'ro',
    isa => enum([qw/string integer float double boolean date anyURI/])
);

no Moose;

1;

