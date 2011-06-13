package GitHub::Collector::Command::lang;

use Moose;
use boolean;

extends qw(MooseX::App::Cmd::Command);

with qw(
  GitHub::Collector::Role::Logger
  GitHub::Collector::Role::Context
  GitHub::Collector::Role::MongoDB
);

sub execute {
    my $self = shift;

    $self->log("start to tag user using langs");

    my $profiles = $self->db_profiles->find({ language => undef } );

    while (my $profile = $profiles->next){
        $self->_tag_profile_by_lang($profile);
    }
    
    $self->log("done tagging users");
}

sub _tag_profile_by_lang {
    my ( $self, $profile ) = @_;

    my $languages = {};

    $self->_repos( $languages, $profile->{login} );
    $self->_contribs( $languages, $profile->{login} );

    my $lang = (
        sort { $languages->{$b} <=> $languages->{$a} }
          keys %$languages
    )[0];

    $lang = "none "if ( !$lang );

    $self->log( "pour " . $profile->{login} . " on a " . $lang );
    $self->db_profiles->update(
        { login  => $profile->{login}, },
        { '$set' => { language => $lang } }
    );
}

sub _repos {
    my ( $self, $languages, $login ) = @_;

    my $repositories = $self->db_repositories->find( { owner => $login } );

    while ( my $repo = $repositories->next ) {
        $languages->{ $repo->{lang} }++ if $repo->{lang};
    }
}

sub _contribs {
    my ( $self, $languages, $login ) = @_;

    my $contribs = $self->db_contributors->find( { contributor => $login } );

    while ( my $contrib = $contribs->next ) {
        my $repo = $self->db_repositories->find_one(
            { uniq_name => $contrib->{project} } );
        $languages->{ $repo->{lang} }++ if $repo->{lang};
    }
}

1;
