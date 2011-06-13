package GitHub::Collector::Command::country;

use Moose;
use boolean;

extends qw(MooseX::App::Cmd::Command);

has geo_conf => (
    is => 'rw',
    isa => 'HashRef',
    required => 1,
    documentation => 'SPORE configuration for Geo API',
);

with
  'GitHub::Collector::Role::Logger',
  'GitHub::Collector::Role::Context',
  'GitHub::Collector::Role::MongoDB',
  'Net::HTTP::Spore::Role' =>
  { spore_clients => [ { name => 'geo', config => 'geo_conf' } ] };

sub execute {
    my $self = shift;

    $self->log("start to tag user using country");

    my $profiles = $self->db_profiles->find({country_done => false});

    while ( my $profile = $profiles->next ) {
        $self->_tag_profile_by_country($profile);
    }

    $self->log("done tagging users");
}

sub _tag_profile_by_country{
    my ($self, $profile) = @_;

    if ( !defined $profile->{location} ) {
        $self->_update_country($profile->{login}, false);
        return;
    }

    $self->log( "searching for "
          . $profile->{login}
          . " based in "
          . $profile->{location} );

    my $res = $self->geo->search(
        q        => $profile->{location},
        username => $self->geo_conf->{api_username},
    )->body;

    die "no more requests" if $res->{status} && $res->{status}->{value} == 19;
    
    if (my $country = $res->{geonames}->[0]->{countryName}){
        $self->_update_country($profile->{login}, $country);
    }else{
        $self->_update_country($profile->{login}, false)
    }
}

sub _update_country {
    my ( $self, $login, $country ) = @_;

    $self->db_profiles->update( { login => $login },
        { '$set' => { country => $country, country_done => true } } );
}

1;
