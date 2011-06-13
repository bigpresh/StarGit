package GitHub::Collector::Command::indegree;

use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
  GitHub::Collector::Role::Context
  GitHub::Collector::Role::Logger
  GitHub::Collector::Role::MongoDB
);

sub execute {
    my $self = shift;

    my $edges = $self->db_edges->find();

    my $profiles = {};
    while ( my $edge = $edges->next ) {
        $profiles->{ $edge->{target} } += $edge->{weight};
    }

    foreach my $login ( keys %$profiles ) {
        $self->db_profiles->update( { login => $login },
            { '$set' => { indegree => $profiles->{$login} } } );
    }
}

1;
