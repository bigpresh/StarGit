package GitHub::Collector::Role::Context;

use YAML;
use Moose::Role;
with qw(MooseX::ConfigFromFile);

sub get_config_from_file {
    my ( $self, $file ) = @_;
    my $conf = YAML::LoadFile($file);
    $conf;
}

1;
