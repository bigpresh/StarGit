package Graph::GEXF;

# ABSTRACT: Manipulate graph file in GEXF

use Moose;

use Data::UUID::LibUUID;
use Moose::Util::TypeConstraints;

use Graph::GEXF::Node;

with
  'Graph::GEXF::Role::XML',
  'Graph::GEXF::Role::Attributes' =>
  { for => [qw/node edge/], with_method => 1 };

=attr visualization (B<Boolean>)

if set to true, the generated graph will includes visualizations informations

=cut

has visualization => (
    is        => 'ro',
    isa       => 'Bool',
    predicate => 'has_visualization',
);

=attr graph_mode (B<static|dynamic>)

Is your graph static or dynamic.

=cut

has graph_mode => (
    is       => 'ro',
    isa      => enum( [qw/static dynamic/] ),
    required => 1,
    default  => 'static',
);

=attr edge_type (B<directed|undirected|mutual|notset>)

The type of the edges

=cut

has edge_type => (
    is       => 'ro',
    isa      => enum( [qw/directed undirected mutual notset/] ),
    required => 1,
    default  => 'directed',
);

=attr nodes

a HashRef of L<Graph::GEXF::Node> objects.

=cut

=method total_nodes

Return the list of nodes attached to the graph

=cut

=method get_node

Return a node

=cut

=method add_node_attribute($name, $type, [$default_value])

Add attributes to node

=method all_nodes

Return all the nodes

=cut

has nodes => (
    traits     => ['Hash'],
    is         => 'rw',
    isa        => 'HashRef[Graph::GEXF::Node]',
    default    => sub { {} },
    auto_deref => 1,
    handles    => {
        _node_exists => 'exists',
        _add_node    => 'set',
        total_nodes  => 'count',
        get_node     => 'get',
        all_nodes    => 'keys',
    },
);

=method add_node

Add a new node to the graph

=cut

sub add_node {
    my $self = shift;
    my ($id, %attributes);

    # TODO should be possible to add a Graph::GEXF::Node too
    
    if ( @_ == 1 ) {
        $id = shift;
    }
    else {
        if ( ( @_ % 2 ) == 0 ) {
            %attributes = @_;
        }
        else {
            $id = shift;
            %attributes = @_;
        }
    }

    if ($id && $self->_node_exists($id)) {
        die "Can't add node wih id $id: already exists";
    }

    $id = new_uuid_string() if !defined $id;

    my $node = Graph::GEXF::Node->new(id => $id);

    map {
        my $attribute = $self->get_node_attribute($_);
        $node->set_node_attribute(
            $_ => {
                id   => $attribute->{id},
                name => $attribute->{name},
                type => $attribute->{type},
            }
        );
    } $self->attributes_node_list;

    $self->_add_node($id => $node);
    $node;
}

1;

=head1 SYNOPSIS

    # create a new graph
    my $graph = Graph::GEXF->new();

    # add some attributes for nodes
    $graph->add_node_attribute('url', 'string');

    # create a new node and set the label
    my $n1 = $graph->add_node(0);
    $n1->label('Gephi');

    my $n2 = $graph->add_node(1);
    $n2->label('WebAtlas');

    my $n3 = $graph->add_node(2);
    $n3->label('RTGI');

    # create relations between nodes
    $n1->link_to(1, 2);
    $n2->link_to(0);
    $n3->link_to(1);

    # set the value for attributes
    $n1->attribute('url' => 'http://gephi.org/');
    $n2->attribute('url' => 'http://webatlas.fr/');
    $n3->attribute('url' => 'http://rtgi.fr/');

    # render the graph in XML
    my $xml = $graph->to_xml;
