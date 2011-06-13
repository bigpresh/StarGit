package GitHub::Collector::Role::Graph::Search;

use Moose::Role;

sub build_from_query {
    my ($self, $search) = @_;

    $search ||= $self->build_query();

    my $profiles = $self->db_profiles->find($search);

    while ( my $profile = $profiles->next ) {
       $self->neighbors( $profile->{login}, 0 );
    }

    $self->remove_leaves();
}

1;
