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

    my $profile = $self->db_profiles->findOne( { login => $self->login } );
    return undef unless defined $profile;

    return {
        login    => $self->login,
        name     => $profile->{name},
        email    => $profile->{email},
        website  => $profile->{website},
        gravatar => $profile->{gravatar},
    };
}

1;
