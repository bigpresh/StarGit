package Graph::GEXF::Role::Viz::Color;

use Moose::Role;
use Moose::Util::TypeConstraints;

subtype RGBColor => as 'Num' => where { $_ >= 0 && $_ <= 255 };
subtype Alpha => as 'Num' => where { $_ > 0 and $_ <= 1 };

my $_has_colors  = 0;

has [qw/r g b/] => (
    is      => 'rw',
    isa     => 'RGBColor',
    default => 0,
    trigger => sub {$_has_colors++},
    traits  => ['Chained'],
);

has a => (
    is      => 'rw',
    isa     => 'Alpha',
    default => 1,
    traits  => ['Chained'],
);

sub has_colors { $_has_colors }

no Moose::Util::TypeConstraints;
no Moose::Role;


1;
