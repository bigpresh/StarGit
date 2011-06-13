package GitHub::Collector::Role::Graph::Gexf;

use Moose::Role;
use Graph::GEXF;

has output => (
    is        => 'ro',
    isa       => 'Int',
    predicate => 'should_export',
);

sub export {
    my ($self, ) = @_;

    my $gexf = Graph::GEXF->new();
    $gexf->add_node_attribute( name    => 'string' );
    $gexf->add_node_attribute( lang    => 'string' );
    $gexf->add_node_attribute( size    => 'int' );
    $gexf->add_node_attribute( country => 'string' );
    $gexf->add_node_attribute( indegree => 'int' );

    my $nodes = {};
    foreach my $node ( keys %{ $self->nodes } ) {
        my $n = $gexf->add_node( $self->nodes->{$node}->{id} );
        $n->label($node);
        $n->attribute( name     => $node );
        $n->attribute( size     => $self->nodes->{$node}->{size} );
        $n->attribute( lang     => $self->nodes->{$node}->{language} || '' );
        $n->attribute( country  => $self->nodes->{$node}->{country} || '' );
        $n->attribute( indegree => $self->nodes->{$node}->{indegree} );
        $nodes->{$node} = $n;
    }

    foreach my $edge (keys %{$self->edges}){
        $nodes->{ $self->edges->{$edge}->{sourceId} }->link_to(
            {
                target => $self->edges->{$edge}->{targetId},
                weight => $self->edges->{$edge}->{weight}
            }
        );
    }

    my $xml = $gexf->to_xml();
    print $xml;
}

1;
