package Grapevine;
use Mojo::Base 'Mojolicious';

use Grapevine::Schema;

has schema => sub {
    my $dsn = "dbi:Pg:dbname=$ENV{GV_DBNAME}";
    return Grapevine::Schema->connect(
        $dsn, $ENV{GV_DBUSER}, $ENV{GV_DBPASS}, {RaiseError => 1}
    );
};

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->helper(db => sub { $self->app->schema });

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('example#welcome');
}

1;
