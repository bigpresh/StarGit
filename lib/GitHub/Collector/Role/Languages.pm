package GitHub::Collector::Role::Languages;

use Moose::Role;

has mapping => (
    is => 'ro',
    isa => 'HashRef',
);

sub map_languages {
    my ( $self, $language ) = @_;

    return "Other" if !defined $language;

    my $languages_map = $self->mapping->{languages};

    if ( defined $languages_map->{$language} ) {
        return $languages_map->{$language};
    }
    else {
        return "Other";
    }
}

1;
