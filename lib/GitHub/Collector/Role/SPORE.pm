package GitHub::Collector::Role::SPORE;

use Moose::Role;
use Net::HTTP::Spore;

has spore_configuration => (
    is            => 'ro',
    isa           => 'HashRef',
    required      => 1,
    documentation => 'SPORE configuration',
);

has spore_client => (
    is => 'rw',
    isa => 'Object',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $client = Net::HTTP::Spore->new_from_spec(
            $self->spore_configuration->{github}->{description},
        );
        $client->enable('Format::JSON');
        $client;
    }
);

1;
