package GitHub::Collector::Command::profile;

use YAML;
use Try::Tiny;
use Moose;
use boolean;

extends qw(MooseX::App::Cmd::Command);

with qw(
  GitHub::Collector::Role::Context
  GitHub::Collector::Role::Logger
  GitHub::Collector::Role::SPORE
  GitHub::Collector::Role::Profile
  GitHub::Collector::Role::MongoDB
  GitHub::Collector::Role::Pause
);

has seed => (
    isa           => 'ArrayRef',
    is            => 'ro',
    required      => 1,
    auto_deref    => 1,
    documentation => 'seed to crawl',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->context->{seed};
    }
);

sub execute {
    my $self = shift;

    $self->log("start to crawl profiles");
    
    foreach my $profile ($self->seed) {
        $self->_bootstrap_profile($profile);
    }

    $self->log("finish to boostrap the seed");
    $self->_crawl(0);
    $self->log("crawl completed");
}

sub get_profile {
    my ( $self, $profile ) = @_;

    my $login = $profile->{login};

    my $profile_info = $self->fetch_profile($login);

    return unless $profile_info;

    $self->save_profile($profile_info);
    $self->add_relations($login);
    $self->profile_is_done($login);
}

sub _crawl {
    my $self = shift;

    my $profiles_to_crawl = $self->db_profiles->find({done => false});

    while (my $profile = $profiles_to_crawl->next) {
        $self->get_profile($profile);
    }

    if ($self->db_profiles->find({done => false})->count > 0) {
        $self->_crawl;
    }
}

sub _bootstrap_profile {
    my ( $self, $profile ) = @_;

    my $has_profile = $self->db_profiles->find( { login => $profile } );
    return if $has_profile->count > 0;
    $self->debug("insert $profile into profiles");
    my $res = $self->db_profiles->insert(
        { login => $profile, done => false, repositories_done => false } );
}

1;

=head1 NAME

GitHub::Collector::Command::profile - foo

=cut
