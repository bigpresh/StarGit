package GitHub::Collector::Command::repository;

use Moose;
use boolean;

extends qw(MooseX::App::Cmd::Command);

with qw(
  GitHub::Collector::Role::Context
  GitHub::Collector::Role::Logger
  GitHub::Collector::Role::SPORE
  GitHub::Collector::Role::MongoDB
  GitHub::Collector::Role::Repository
);

sub execute {
    my $self = shift;

    $self->log("start to crawl repositories");
    $self->_crawl();
    $self->log("crawl completed");
}

sub get_repositories {
    my ($self, $profile) = @_;

    my $login = $profile->{login};

    $self->log("fetch repositories for $login");
    $self->fetch_repositories($profile);
    $self->log("finished to work on $login");
}

sub _crawl {
    my $self = shift;

    my $profiles = $self->db_profiles->find( { repositories_done => false } );

    while ( my $profile = $profiles->next ) {
        $self->get_repositories($profile);
    }
}

1;
