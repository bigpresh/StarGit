package GitHub::Collector::Role::Graph::Neighbors;

use Moose::Role;
with qw(GitHub::Collector::Role::Languages);

sub neighbors {
    my ( $self, $name, $with_connections ) = @_;

    $self->_neighbors($name);

    if ($with_connections) {
        foreach my $id ( keys %{ $self->edges } ) {
            $self->_connections( $id, $name );
        }
    }
}

sub _neighbors {
    my ( $self, $name ) = @_;

    if ( !defined $self->nodes->{$name} ) {
        $self->_create_node($name);
    }

    $self->_fetch_edges_from($name);
    $self->_fetch_edges_to($name);
}

sub _connections {
    my ( $self, $id, $name ) = @_;

    if ( $self->edges->{$id}->{sourceId} eq $name ) {
        $self->_neighbors( $self->edges->{$id}->{targetId} );
    }
    else {
        $self->_neighbors( $self->edges->{$id}->{sourceId} );
    }
}

sub remove_leaves {
    my $self = shift;

    foreach my $id ( keys %{$self->nodes} ) {
        if ( $self->nodes->{$id}->{size} < 2 ) {
            delete $self->nodes->{$id};
        }
    }

    foreach my $id ( keys %{$self->edges} ) {
        unless ( $self->nodes->{ $self->edges->{$id}->{sourceId} }
            && $self->nodes->{ $self->edges->{$id}->{targetId} } )
        {
            delete $self->edges->{ $id };
        }
    }
}

sub _fetch_edges_from {
    my ( $self, $name ) = @_;

    my $connections = $self->db_edges->find( { source => $name } );

    while ( my $edge = $connections->next ) {
        my $edge_id = $edge->{source} . $edge->{target};

        if ( !defined $self->edges->{$edge_id} ) {
            $self->edges->{$edge_id} = {
                id       => $edge_id,
                targetId => $edge->{target},
                sourceId => $name,
                weight   => $edge->{weight},
            };

            $self->nodes->{$name}->{size}++;

            if ( defined $self->nodes->{ $edge->{target} } ) {
                $self->nodes->{ $edge->{target} }->{size}++;
            }
            else {
                $self->_create_node( $edge->{target}, 1 );
            }
        }
    }
}

sub _fetch_edges_to {
    my ($self, $name) = @_;
    my $connections = $self->db_edges->find( { target => $name } );
    while ( my $edge = $connections->next ) {
        my $edge_id = $edge->{source} . $edge->{target};

        if ( !defined $self->edges->{$edge_id} ) {
            $self->edges->{$edge_id} = {
                id       => $edge_id,
                targetId => $name,
                sourceId => $edge->{source},
                weight   => $edge->{weight},
            };

            $self->nodes->{$name}->{size}++;

            if ( defined $self->nodes->{ $edge->{source} } ) {
                $self->nodes->{ $edge->{source} }->{size}++;
            }
            else {
                $self->_create_node( $edge->{source}, 1 );
            }
        }
    }
}

sub _create_node {
    my ( $self, $login, $size ) = @_;

    $size ||= 0;

    my $info = $self->db_profiles->find_one( { login => $login } );
    $self->nodes->{$login} = {
        id       => $login,
        label    => $login,
        size     => $size,
        language => $self->map_languages($info->{language}),
        country  => $info->{country} || '',
        indegree => $info->{indegree},
    };
}

1;
