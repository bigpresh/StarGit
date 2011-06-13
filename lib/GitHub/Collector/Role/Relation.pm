package GitHub::Collector::Role::Relation;

use Try::Tiny;
use Moose::Role;

with qw/GitHub::Collector::Role::Pause/;

has types => (
    is          => 'ro',
    isa         => 'ArrayRef',
    auto_deref => 1,
    default     => sub { [qw/followers following/] }
);

sub add_relations {
    my ( $self, $login ) = @_;

    foreach my $type ($self->types) {
        my $users = $self->_grab_relations( $login, $type );
        foreach my $user (@$users) {
            $self->_bootstrap_profile($user);
            if ($type eq 'followers'){
                $self->_add_relation($user, $login);
            }else{
                $self->_add_relation($login, $user);
            }
        }
    }
}

sub _grab_relations {
    my ( $self, $login, $type ) = @_;

    $self->log( [ "fetching %s informations for %s", $type, $login ] );

    my $method = 'list_' . $type;
    my ( $users, $error );
    try {
        $users = $self->spore_client->$method(
            format => 'json',
            user   => $login,
        )->body->{users};
    }
    catch {
        $error = $_;
        if ( $error->status == 403 ) {
            $self->debug(
                [ "need to pause (while grabbing relations for %s)", $login ] );
            sleep($self->pause_on_error);
            $self->_grab_relations( $login, $type );
        }
        else {
            $self->debug(
                [ "can't fetch %s relation for %s: %s", $type, $login, $error ]
            );
        }
    };

    sleep( $self->pause );
    return $users;
}

sub _add_relation {
    my ($self, $source, $target) = @_;
    my $search = {source => $source, target => $target};
    my $exists = $self->db_relations->find_one($search);
    $self->db_relations->insert($search) if !$exists;
}

1;
