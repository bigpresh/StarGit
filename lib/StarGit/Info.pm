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
        website  => $profile->{blog} || "none",
        gravatar => $profile->{gravatar_id},
        indegree => $profile->{indegree} || 0,
        country  => $profile->{country} || "unknown",
        language => $profile->{language} || "unknown",
    };
}

1;
