package GitHub::Collector::Role::Profile;

use Try::Tiny;
use Moose::Role;
use boolean;

with qw/
    GitHub::Collector::Role::Pause
    GitHub::Collector::Role::Relation
    /;

sub fetch_profile {
    my ( $self, $profile ) = @_;

    my ( $res, $error );

    try {
        $res = $self->spore_client->get_info(
            format   => 'json',
            username => $profile,
        );
    }
    catch {
        $error = $_;
    };

    if ($error) {
        if ($error->status == 403){
            $self->debug( [ "need to pause (while working on %s)", $profile ] );

            sleep( $self->pause_on_error );
            return $self->fetch_profile($profile);
        }elsif($error->status == 404){
            $self->debug("profile $profile doesn't exists anymore");
            $self->delete_profile($profile);
            return;
        }else{
            $self->return("can't fetch information for $profile: $error");
            return;
        }
    }
    sleep($self->pause);
    return $res->body;
}

sub save_profile {
    my ( $self, $profile_info ) = @_;

    my $id   = delete $profile_info->{user}->{id};
    my $time = time();

    $self->db_profiles->update(
        { login => $profile_info->{user}->{login} },
        {
            '$set' => {
                crawled_at        => $time,
                repositories_done => false,
                %{ $profile_info->{user} }
            },
        }
    );

    $self->log( "profile " . $profile_info->{user}->{login} . " saved" );
}

sub delete_profile {
    my ($self, $profile) = @_;

    $self->db_profiles->remove({login => $profile});
    foreach my $type (qw/target source/){
        $self->db_relations->remove({$type => $profile});
    }
    $self->log("all informations regarding $profile have been deleted");
}

sub profile_is_done {
    my ( $self, $login ) = @_;
    $self->db_profiles->update(
        { login  => $login },
        { '$set' => { done => true } },
    );
}

1;
