package GitHub::Collector::Role::Pause;

use Moose::Role;

has pause_on_error => (
    is      => 'ro',
    isa     => 'Int',
    default => 10,
);

sub pause {
    my $self = shift;
    my $rand = int(rand(10));
    my $pause = $rand == 1 ? $rand : 0;
    sleep($pause);
}

1;
