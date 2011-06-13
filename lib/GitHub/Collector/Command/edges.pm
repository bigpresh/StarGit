package GitHub::Collector::Command::edges;

use Moose;
use boolean;

extends qw(MooseX::App::Cmd::Command);

with qw(
  GitHub::Collector::Role::Context
  GitHub::Collector::Role::Logger
  GitHub::Collector::Role::MongoDB
);

sub execute {
    my $self = shift;

    $self->log("start to merge contributions");

    my $profiles = $self->db_profiles->find({edges_done => false});

    while ( my $profile = $profiles->next ) {
        next if $self->_is_done($profile->{login});
        $self->log("merge contributions for ".$profile->{login});
        $self->_contributions($profile->{login});
    }

    $self->log("done merging contributions");
}

sub _is_done {
    my ($self, $login) = @_;
    $self->db_edges->find({source => $login})->count;
}

sub _contributions {
    my ( $self, $login ) = @_;

    my $contributions =
      $self->db_contributors->find( { contributor => $login } );

    my $profiles = {};

    while ( my $contrib = $contributions->next ) {
        my $project = $self->db_repositories->find_one(
            { uniq_name => $contrib->{project} } );

        next if $project->{size} == 0;
        my $total =
          int( ( $contrib->{contributions} / $project->{size} ) * 100 );
        $total ||= 1;
        $profiles->{ $contrib->{owner} } += $total;
    }

    foreach my $pr ( keys %$profiles ) {
        $self->db_edges->insert({
            source => $login,
            target => $pr,
            weight => $profiles->{$pr}
        });
    }
    $self->db_profiles->update(
        { login  => $login },
        { '$set' => { edges_done => true } },
    );
}

1;    
