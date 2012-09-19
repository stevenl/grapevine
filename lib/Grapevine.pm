package Grapevine;
use Mojo::Base 'Mojolicious';

use Grapevine::Schema;

has schema => sub {
    return Grapevine::Schema->connect(
        "dbi:Pg:dbname=$ENV{GV_DBNAME};host=$ENV{GV_DBHOST};port=$ENV{GV_DBPORT};",
        $ENV{GV_DBUSER}, $ENV{GV_DBPASS},
        { RaiseError => 1, quote_char => '"' }
    );
};

# This method will run once at server start
sub startup {
    my $self = shift;

    for (qw[ GV_DBNAME GV_DBHOST GV_DBPORT GV_DBUSER GV_DBPASS ]) {
        die "Environment variable '$_' must be set" if ! defined $ENV{$_};
    }
    $self->helper(db => sub { $self->app->schema });

    # Router
    my $r = $self->routes;
    $r->get('/')->to('example#welcome');

    # users
    $r->get('/users/new')->to('users#enter_new');
    $r->post('/users/new/submit')->to('users#submit_new');
    $r->get('/users/login')->to('users#login')->name('login');
    $r->post('/users/login/submit')->to('users#submit_login');
    $r->get('/users/logout')->to('users#logout')->name('logout');

    # questions
    $r->get('/questions/new')->to('questions#enter_new');
    $r->post('/questions/new/submit')->to('questions#submit_new');
    $r->get('/questions/:question_id')->to('questions#show');
    $r->get('/questions')->to('questions#list');

    # deals
    $r->get('/deals/new')->to('deals#enter_new');
    $r->post('/deals/new/submit')->to('deals#submit_new');
    $r->get('/deals/:deal_id')->to('deals#show');
    $r->get('/deals')->to('deals#list');
}

1;
