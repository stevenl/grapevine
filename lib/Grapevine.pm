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
    $r->get('/')->name('home')
      ->to('example#welcome');

    # users
    $r->get('/users/signup')->name('new_signup')
      ->to('users#enter_new');
    $r->post('/users/signup/submit')->name('submit_signup')
      ->to('users#submit_new');
    $r->get('/users/login')->name('login')
      ->to('users#login');
    $r->post('/users/login/submit')->name('submit_login')
      ->to('users#submit_login');
    $r->get('/users/logout')->name('logout')
      ->to('users#logout');

    # questions
    $r->get('/questions/ask')->name('ask_question')
      ->to('questions#enter_new');
    $r->post('/questions/ask/submit')->name('submit_question')
      ->to('questions#submit_new');
    $r->get('/questions/:question_id')->name('question')
      ->to('questions#show');
    $r->get('/questions')->name('questions_list')
      ->to('questions#list');

    # deals
    $r->get('/deals/new')->name('new_deal')
      ->to('deals#enter_new');
    $r->post('/deals/new/submit')->name('submit_deal')
      ->to('deals#submit_new');
    $r->get('/deals/:deal_id')->name('deal')
      ->to('deals#show');
    $r->get('/deals')->name('deals_list')
      ->to('deals#list');
}

1;
