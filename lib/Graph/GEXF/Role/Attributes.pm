package Graph::GEXF::Role::Attributes;

use MooseX::Role::Parameterized;

parameter for => (
    is       => 'ro',
    required => 1,
);

parameter with_method => (
    is      => 'ro',
    default => 0,
);

role {
    my $p = shift;

    foreach my $type (@{$p->for}) {

        my $attr_name  = $type . '_attributes';
        my $total_attr = 'attributes_' . $type . '_total';
        my $set_attr   = 'set_' . $type . '_attribute';
        my $get_attr   = 'get_' . $type . '_attribute';
        my $list_attr  = 'attributes_' . $type . '_list';
        my $has_attr   = 'has_' . $type . '_attribute';

        has $attr_name => (
            traits  => ['Hash'],
            is      => 'rw',
            isa     => 'HashRef',
            lazy    => 1,
            default => sub { {} },
            handles => {
                $total_attr => 'count',
                $set_attr   => 'set',
                $get_attr   => 'get',
                $list_attr  => 'keys',
                $has_attr   => 'exists',
            }
        );

        if ($p->with_method) {
            my $method_name = 'add_' . $type . '_attribute';

            method $method_name => sub {
                my ($self, $name, $type, $default_value) = @_;
                my $id = $self->$total_attr();
                my $attr = {
                    id      => $id,
                    title   => $name,
                    type    => $type,
                    default => [$default_value],
                };
                $self->$set_attr($name => $attr);
            };
        }
    }
};

1;
