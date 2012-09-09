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

    # deals
    $r->get('/deals/new')->to('deals#enter_new');
    $r->post('/deals/new/submit')->to('deals#submit_new');
    $r->get('/deals/:deal_id')->to('deals#show');
    $r->get('/deals')->to('deals#list');
}

1;
