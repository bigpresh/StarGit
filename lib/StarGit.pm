package StarGit;
use Dancer ':syntax';

use StarGit::Graph;
use Dancer::Plugin::Memcached;

our $VERSION = '0.1';

set serializer => 'JSON';

get '/' => sub {
    template 'index';
};

get '/graph/local/:name' => sub {
    my $name = params->{'name'};

    my $graph =
      StarGit::Graph->new( name => $name, mongodb_auth => setting('mongodb') );

    return send_error( "user " . $name . " doesn't exists", 404 )
      unless $graph->exists($name);

    $graph->neighbors( $name, 1 );
    $graph->remove_leaves();

    my $serialized_graph = _finalize($graph);
    memcached_store($name, $serialized_graph);
    return $serialized_graph;
};

# XXX do we already use this one ?
get '/graph/query' => sub {
    my $language = params->{language};

    my $graph = StarGit::Graph->new( language => $language );
    $graph->build_from_query();

    my $serialized_graph = _finalize($graph);
    return $serialized_graph;
};

get '/graph/attributes' => sub {
    my $graph_settings = setting('graph');
    my $attributes     = $graph_settings->{attributes};
    return { attributes => $attributes };
};

get '/profile/:login' => sub {
    my $login = params->{login};
    my $info = StarGit::Info->new( login => $login );
    if ( !defined $info ) {
        return send_error( "no information for profile " . $login );
    }
    return $info;
};

sub _finalize {
    my $graph = shift;

    my @nodes = values %{ $graph->nodes };
    my @edges = values %{ $graph->edges };

    return { nodes => \@nodes, edges => \@edges, };
}

true;
