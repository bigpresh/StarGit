package StarGit::Info;

use Moose;

has login => (
    isa => 'Str',
    required => 1,
    is => 'ro',
);

with qw(
  GitHub::Collector::Role::MongoDB
);

sub get {
    my $self = shift;

    my $profile = $self->db_profiles->find_one( { login => $self->login } );

    return {
        login    => $self->login,
        name     => $profile->{name} || $self->login,
        website  => $profile->{blog},
        gravatar => $profile->{gravatar_id},
        indegree => $profile->{indegree},
        country => $profile->{country} || "",
        language => $profile->{language} || "",
    };
}

1;
