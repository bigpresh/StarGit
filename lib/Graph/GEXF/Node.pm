package Graph::GEXF::Node;

use Moose;
use Graph::GEXF::Edge;

with
  'Graph::GEXF::Role::Attributes' => { for => [qw/node/] },
  'Graph::GEXF::Role::Viz::Color', 'Graph::GEXF::Role::Viz::Position',
  'Graph::GEXF::Role::Viz::Size'  => { as  => 'size' },
  'Graph::GEXF::Role::Viz::Shape' => { for => 'node' };

has id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    traits   => ['Chained']
);

has label => (
    is     => 'rw',
    isa    => 'Str',
    traits => ['Chained']
);

has edges => (
    traits  => ['Hash'],
    is      => 'rw',
    isa     => 'HashRef[Graph::GEXF::Edge]',
    default => sub { {} },
    handles => {
        add_edge    => 'set',
        has_link_to => 'exists',
        all_edges   => 'keys',
        get_edge    => 'get',
    }
);

sub link_to {
    my $self     = shift;
    my @nodes_id = @_;

    foreach my $node_id (@nodes_id) {
        my $edge;
        if ( ref $node_id ) {
            $edge = Graph::GEXF::Edge->new(
                source => $self->id,
                target => $node_id->{target},
                weight => $node_id->{weight}
            );
            $self->add_edge( $node_id->{target} => $edge );
        }
        else {
            $edge = Graph::GEXF::Edge->new(
                source => $self->id,
                target => $node_id,
            );
            $self->add_edge( $node_id => $edge );
        }
    }
}

sub attribute {
    my ($self, $attribute_name, $value) = @_;

#    return 0 unless $self->has_node_attribute;

    if (!$self->has_node_attribute($attribute_name)) {
        die "this attribute doesn't exists";
    }

    $self->node_attributes->{$attribute_name}->{value} = $value;

    1;
}

no Moose;

1;

=head1 SYNOPSIS

    my $graph = Graph::GEXF->new();

    my $n = $graph->add_node();

=head1 DESCRIPTION

=head2 ATTRIBUTES

=head3 id

    my $n = $graph->add_node(1);
    $n->id; # returns 1

The B<id> of a node can't be changed once the node is created.

=head3 label

    $n->label('franckcuny');
    $n->label();

Each node has a label. If the B<label> is not defined, the default value is the B<id>. This value can be changed at any time.

=head3 viz

If B<visualization> is set to true, thoses values will be added to the XML.

=over

=item r,g,b,a

    $n->r(255);

=head3 x,y,z

    $n->x(1);

=head3 shape

    $n->shape('disc');

can be any of B<disc>, B<square>, B<triangle>, B<diamond>.

=head3 size

    $n->size(2);

=back

=head2 METHODS

=head3 link_to

   my $n1 = $graph->add_node();
   my $n2 = $graph->add_node();
   my $n3 = $graph->add_node();

   $n1->link_to($n2->id);
   $n1->link_to($n3->id);

   # or
   $n1->link_to($n2->id, $n3->id);

This method will create an edge between some nodes.

=head3 attribute

=head3 add_edge

=head3 has_link_to

=head3 all_edges

=head3 get_edge

