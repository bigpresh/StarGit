package Graph::GEXF::Role::XML;

use Moose::Role;

use XML::Simple;

has gexf_ns => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http://www.gexf.net/1.2draft'
);

has gexf_version => (
    is      => 'ro',
    isa     => 'Num',
    default => '1.2'
);

sub to_xml {
    my $self = shift;

    my $graph = $self->_init_graph();

    foreach (qw/node edge/) {
        $self->_add_attributes( $graph, $_ );
    }

    $self->_add_nodes($graph);

    my $xml_out = XMLout($graph, AttrIndent => 1, keepRoot => 1);
    $xml_out;
}

sub _add_attributes {
    my ($self, $graph, $type) = @_;

    my $list_attr = 'attributes_' . $type . '_list';
    my $get_attr  = 'get_' . $type . '_attribute';

    my $attributes;
    $attributes->{class} = $type;

    foreach my $attr_id ($self->$list_attr) {
        my $attribute = $self->$get_attr($attr_id);
        push @{$attributes->{attribute}},
          { id      => $attribute->{id},
            type    => $attribute->{type},
            title   => $attribute->{title},
            default => $attribute->{default},
          };
    }

    push @{$graph->{gexf}->{graph}->{attributes}}, $attributes;
}

sub _init_graph {
    my $self = shift;

    # XXX this need some refactoring
    return {
        gexf => {
            xmlns   => $self->gexf_ns,
            version => $self->gexf_version,
            meta    => {creator => ['Graph::GEXF']},
            graph   => {
                mode            => $self->graph_mode,
                defaultedgetype => $self->edge_type,
            }
        }
    };
}

sub _add_nodes {
    my ( $self, $graph ) = @_;

    my $edges_id = 0;

    foreach my $node_id ( $self->all_nodes ) {
        my $node = $self->get_node($node_id);
        my ( $node_desc, $edges ) = $self->_create_node($node);
        push @{ $graph->{gexf}->{graph}->{nodes}->{node} }, $node_desc;
        foreach my $edge (@$edges) {
            push @{ $graph->{gexf}->{graph}->{edges}->{edge} }, $edge;
        }
    }
}

sub _create_node {
    my ( $self, $node ) = @_;

    my $label = $node->label || $node->id;

    my $node_desc = { id => $node->id, label => $label };

    foreach my $attr_id ( $node->attributes_node_list ) {
        my $attr = $node->get_node_attribute($attr_id);
        push @{ $node_desc->{attvalues}->{attvalue} },
          { for => $attr->{id}, value => $attr->{value} };
    }

    $self->_add_visualizations_elements($node, $node_desc);

    my @edges =
      map { $self->_create_edge( $node->get_edge($_) ) } $node->all_edges;

    return ($node_desc, \@edges);
}

sub _create_edge {
    my ( $self, $edge ) = @_;
    my $edge_desc = {
        id     => $edge->id,
        source => $edge->source,
        target => $edge->target,
        weight => $edge->weight,
    };

    $self->_add_shape($edge, $edge_desc);
    
    return $edge_desc;
}

sub _add_visualizations_elements {
    my ( $self, $node, $node_desc ) = @_;

    return unless $self->has_visualization;

    foreach (qw/colors size shape position/){
        my $method = "_add_$_";
        $self->$method($node, $node_desc);
    }
}

sub _add_colors {
    my ( $self, $element, $element_desc ) = @_;

    return unless $element->has_colors;
    push @{ $element_desc->{'viz:color'} },
      $self->_add_viz_elements( $element, qw/r g b a/ );
}

sub _add_size {
    my ($self, $element, $element_desc) = @_;
    push @{$element_desc->{'viz:size'}}, {value => $element->size};
}

sub _add_shape {
    my ($self, $element, $element_desc) = @_;
    push @{$element_desc->{'viz:shape'}}, {value => $element->shape};
}

sub _add_position {
    my ($self, $element, $element_desc) = @_;

    return unless $element->has_position;
    push @{ $element_desc->{'viz:position'} },
      $self->_add_viz_elements( $element, qw/x y z/ );
}

sub _add_viz_elements {
    my ( $self, $element, @attrs ) = @_;
    my %hash = map { $_ => $element->$_ } @attrs;
    \%hash;
}

no Moose::Role;

1;
