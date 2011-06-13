package GitHub::Collector::Role::Repository;

use Moose::Role;
use Try::Tiny;
use boolean;

with qw/GitHub::Collector::Role::Pause/;

sub fetch_repositories {
    my ( $self, $profile ) = @_;

    my ( $repositories, $languages, $error );

    try {
        $repositories = $self->spore_client->list_repos(
            user   => $profile->{login},
            format => 'json',
        )->body->{repositories};
    }
    catch {
        $error = $_;
    };

    if ($error) {
        if ( $error->status == 403 ) {
            $self->debug(
                [ "need to pause (while working on %s)", $profile->{login} ] );
            sleep($self->pause_on_error);
            return $self->fetch_repositories($profile);
        }
        else {
            $self->debug("can't fetch repositories for ".$profile->{login}.": $error");
            return;
        }
    }

    foreach my $repo (@$repositories) {

        next if $repo->{fork};
        next unless $repo->{forks};

        $self->_get_lang($profile, $repo, $languages);
        $self->_get_contributors($profile, $repo);
        $self->_save_repository($profile, $repo);
    }

    sleep ($self->pause);
    $self->_update_profile($profile->{login}, $languages);
    return 1;
}

sub _update_profile {
    my ( $self, $login, $languages ) = @_;

    my $lang = $self->_main_lang($languages);

    $self->db_profiles->update(
        { login  => $login },
        { '$set' => { repositories_done => true, language => $lang } },
    );
}

sub _save_repository {
    my ( $self, $profile, $repo ) = @_;

    my $contributors = delete $repo->{contributors};

    if ( scalar @$contributors > 1 ) {
        my $project_name = $profile->{login} . '/' . $repo->{name};

        $repo->{uniq_name} = $project_name;
        $self->db_repositories->insert($repo);

        $self->_save_contributors( $profile->{login}, $project_name,
            $contributors );

        $self->log(
            [
                'Add repository %s owned by %s', $repo->{name},
                $profile->{login}
            ]
        );
    }
}

sub _save_contributors {
    my ( $self, $owner, $project_name, $contributors ) = @_;

    $self->log(
        [ 'Add %s contributor(s) to %s', scalar @$contributors, $project_name ]
    );

    foreach my $contrib (@$contributors) {
        next if $owner eq $contrib->{login};
        $self->db_contributors->insert(
            {
                project       => $project_name,
                owner         => $owner,
                contributor   => $contrib->{login},
                contributions => $contrib->{contributions},
            }
        );
    }
}

sub _get_lang {
    my ( $self, $profile, $repo, $languages ) = @_;

    my $pr_languages;
    try {
        $pr_languages = $self->spore_client->list_languages(
            user   => $profile->{login},
            repo   => $repo->{name},
            format => 'json'
        )->body->{languages};
    }
    catch {
        my $error = $_;
        if ( $error->status == 403 ) {
            $self->debug(
                [ "need to pause (while getting lang for %s)", $repo->{name} ]
            );
            sleep($self->pause_on_error);
            $self->_get_lang( $profile, $repo, $languages );
        }
    };
    foreach my $l ( keys %$pr_languages ) {
        $languages->{$l} += $pr_languages->{$l};
    }

    my $lang = $self->_main_lang($pr_languages);
    $repo->{lang} = $lang;
}

sub _main_lang {
    my ( $self, $languages ) = @_;
    my $lang = (
        sort { $languages->{$b} <=> $languages->{$a} }
          keys %$languages
    )[0];
    return $lang;
}

sub _get_contributors {
    my ( $self, $profile, $repo ) = @_;

    try {
        my $contributors = $self->spore_client->list_contributors(
            user   => $profile->{login},
            repo   => $repo->{name},
            format => 'json'
        )->body->{contributors};
        $repo->{contributors} = scalar @$contributors > 1 ? $contributors : [];
    }
    catch {
        my $error = $_;
        if ( $error->status == 403 ) {
            $self->debug(
                [
                    "need to pause (while getting contributors for %s)",
                    $repo->{name}
                ]
            );
            sleep($self->pause_on_error);
            $self->_get_contributors( $profile, $repo );
        }
        else {
            $repo->{contributors} = [];
        }
    };
}

1;
