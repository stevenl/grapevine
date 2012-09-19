use strict;
use warnings;

use Test::More;
use Test::Mojo;
use Test::DBIx::Class {force_drop_table => 1}, 'User';

my %data1 = (
    username => 'johndoe',
    password => 'letmein',
    email => 'johndoe@example.com',
);
my %data2 = (
    username => 'janedoe',
    password => 'password',
    email => 'jane@example.com',
);

my $t = Test::Mojo->new('Grapevine');
$t->ua->max_redirects(5);
User->create(\%data1);

# new
{
    $t->get_ok('/users/signup')
      ->status_is(200)
      ->element_exists('form[method="post"][action="/users/signup/submit"]')
      ->element_exists('form input[name="username"][type="text"]')
      ->element_exists('form input[name="password"][type="password"]')
      ->element_exists('form input[name="email"][type="text"]')
      ->element_exists('form input[type="submit"]');
}

# submit new
{
    $t->post_form_ok('/users/signup/submit' => \%data2)->status_is(200);
    is $t->tx->req->url->path, '/';
}

# login
{
    $t->get_ok('/users/login')
      ->status_is(200)
      ->element_exists('form[method="post"][action="/users/login/submit"]')
      ->element_exists('form input[name="username"][type="text"]')
      ->element_exists('form input[name="password"][type="password"]')
      ->element_exists('form input[type="submit"]');
}

# submit login (fail authentication)
{
    $t->post_form_ok('/users/login/submit' => {username => 'badegg'})
      ->status_is(200)
      ->text_is('#message' => 'username or password is invalid')
      ->element_exists('form input[name="username"][value="badegg"]');
}

# submit login
{
    $t->post_form_ok('/users/login/submit' => \%data2)->status_is(200);
    is $t->tx->req->url->path, '/';
}

# logout
{
    $t->get_ok('/users/logout')->status_is(200);
}

done_testing();
