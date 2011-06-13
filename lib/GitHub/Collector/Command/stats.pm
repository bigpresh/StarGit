package GitHub::Collector::Command::stats;

use 5.010;
use Moose;
use boolean;
use JSON;
use DateTime;

extends qw(MooseX::App::Cmd::Command);

with qw(
  GitHub::Collector::Role::Context
  GitHub::Collector::Role::Logger
  GitHub::Collector::Role::MongoDB
  GitHub::Collector::Role::Languages
);

sub execute {
    my ($self, ) = @_;

    my $profiles = $self->db_profiles->find();

    my $languages = {};
    my $country   = {};
    my $company   = {};
    my $created   = {};

    while ( my $profile = $profiles->next ) {
        my $date = $profile->{created_at};

        next if !defined $date;

        my ($year, $month) = $date =~ /(\d{4})(?:-|\/)(\d{2})/;
        next if (!defined $year || !defined $month);

        my $lang = $self->map_languages( $profile->{language} );
        $languages->{$lang}++ if $lang ne 'Other';

        $country->{ $profile->{country} }++ if $profile->{country};
        $company->{ $profile->{company} }++ if defined $profile->{company};

        $created->{global}->{ $year . '/' . $month }->{total}++;
        $created->{languages}->{$lang}->{ $year . '/' . $month }->{total}++;
    }

#    $self->_sort_and_display($languages);
#    $self->_sort_and_display($country, 10);
#    $self->_sort_and_display($company, 100);

    $self->_create_flot( $created->{global}, 'global' );
    foreach my $lang ( keys %{ $created->{languages} } ) {
        $self->_create_flot( $created->{languages}->{$lang}, $lang );
    }
}

sub _sort_and_display {
    my ($self, $data, $iter) = @_;

    my @sorted = sort {$data->{$b} <=> $data->{$a}} keys %$data;

    my $total = 0;
    map {$total += $data->{$_} } @sorted;
    $iter ||= (scalar @sorted - 1);

    for(0..$iter){
        my $pct = int(($data->{$sorted[$_]} / $total) * 100);
        say " # ".$sorted[$_].":".$data->{$sorted[$_]}. " ($pct%)";
    }
}

sub _create_flot {
    my ($self, $data, $label) = @_;

    my $graph = {};
    $graph->{label} = $label;

    my @sorted = sort {$a cmp $b} keys %$data;

    # remove the first and last value since they're not really worthy
    shift @sorted;
    pop @sorted;

    foreach my $month (@sorted) {
        (my $y, my $m) = $month =~ /(\d{4})\/(\d{2})/;
        my $epoch = DateTime->new(year => $y, month => $m, day => 01)->epoch * 1000;
        push @{$graph->{data}}, [$epoch, $data->{$month}->{total}];
    }

    open my $fh, '>', $label.'.json';
    print $fh JSON::encode_json($graph);
    close $fh;
}

1;
