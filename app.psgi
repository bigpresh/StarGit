#!/usr/bin/env

use Dancer;
use StarGit;

use Plack::Builder;

my $app = sub {
    my $env     = shift;
    my $request = Dancer::Request->new($env);
    Dancer->dance($request);
};

builder {
    enable "ConditionalGET";
    enable "ETag";
    enable "Auth::Basic", authenticator => sub {
        my ( $username, $password ) = @_;
        return $username eq 'github' && $password eq 'octocat';
    };
    $app;
};
