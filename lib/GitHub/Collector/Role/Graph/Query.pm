package GitHub::Collector::Role::Graph::Query;

use Moose::Role;

has language => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_language',
);

has location => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_location',
);

has company => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_company',
);

has country => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_country',
);


sub build_query {
    my $self = shift;

    my $search = {};

    foreach my $attr (qw/language location company country/) {
        my $predicate = "has_$attr";
        if ( $self->$predicate ) {
            $search->{$attr} = $self->$attr;
        }
    }

    return $search;
}

1;
