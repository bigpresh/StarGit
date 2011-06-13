package GitHub::Collector::Command::graph;

use Moose;
use YAML::Syck;

extends qw(MooseX::App::Cmd::Command);

with qw(
  GitHub::Collector::Role::Context
  GitHub::Collector::Role::Logger
  GitHub::Collector::Role::MongoDB
  GitHub::Collector::Role::Graph::Query
  GitHub::Collector::Role::Graph::Nodes
  GitHub::Collector::Role::Graph::Edges
  GitHub::Collector::Role::Graph::Neighbors
  GitHub::Collector::Role::Graph::Search
  GitHub::Collector::Role::Graph::Gexf
);

has profile => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_profile',
);

has indegree => (
    is => 'ro',
    isa => 'Int',
    predicate => 'has_indegree',
);

sub execute {
    my $self = shift;

    if ($self->has_profile){
        $self->neighbors($self->profile, 1);
        $self->remove_leaves();
    }elsif($self->has_indegree){
        $self->build_from_query( { indegree => { '$gt' => $self->indegree } } );
    }else{
        $self->build_from_query();
    }

    $self->export() if $self->should_export;
}

1;
