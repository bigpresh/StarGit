package GitHub::Collector::Role::MongoDB;

use Moose::Role;
use MongoDB;

has mongodb_auth => (
    is         => 'ro',
    isa        => 'HashRef',
    auto_deref => 1,
    default    => sub {{} },
);

has mongodb => (
    is      => 'ro',
    isa     => 'Object',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $conn = MongoDB::Connection->new(
            $self->mongodb_auth );
        my $db = $conn->github;
        $self->_create_indexes($db);
        return $db;
    },
    handles => {
        db_profiles     => 'profiles',
        db_repositories => 'repositories',
        db_relations    => 'relations',
        db_contributors => 'contributors',
        db_edges        => 'edges',
    }
);

sub _create_indexes {
    my ( $self, $db ) = @_;

    $db->profiles->ensure_index( { login => 1 }, { unique => 1 } );
    $db->repositories->ensure_index( { uniq_name => 1 }, { unique => 1 } );
    $db->contributors->ensure_index( { project   => 1 } );
    $db->contributors->ensure_index( { owner     => 1 } );
    $db->relations->ensure_index( { source => 1 } );
    $db->relations->ensure_index( { target => 1 } );
    $db->relations->ensure_index( { login  => 1 } );
    $db->edges->ensure_index({source => 1});
    $db->edges->ensure_index({target => 1});
}

1;
