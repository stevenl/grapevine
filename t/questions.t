use strict;
use warnings;

use Test::More;
use Test::Mojo;
use Test::DBIx::Class {force_drop_table => 1}, 'Question';

my @data = (
  {
    user_id => 1,
    title => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut purus orci, eu tristique nisl.',
    description => 'Praesent semper, tortor in vehicula ullamcorper, massa purus gravida nunc, vitae eleifend erat risus et libero. Nulla nisi lorem, vehicula et consequat in, cursus at metus. Aenean eleifend dictum ipsum a venenatis. Mauris pellentesque commodo arcu sit amet fermentum. Integer porta varius sem, eget blandit quam tempus a. Praesent condimentum tortor odio, ac mattis mauris. Cras iaculis ullamcorper interdum. Donec odio augue, vehicula nec rhoncus non, aliquet id ante. Nullam a malesuada nisl. Aliquam viverra tempor leo ut malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pretium quam et felis eleifend et rhoncus sapien tincidunt.',
  }, {
    user_id => 1,
    title => 'Sed consectetur, neque ut lacinia vestibulum, arcu odio placerat eros, sit amet egestas risus quam vitae nibh.',
    description => 'Quisque neque nulla, interdum eget aliquam sit amet, egestas a magna.',
  }
);

my $t = Test::Mojo->new('Grapevine');
fixtures_ok 'users';
Question->create($data[0]);

# new
{
    $t->get_ok('/questions/new')
      ->status_is(200)
      ->element_exists('form[method="post"][action="/questions/new/submit"]')
      ->element_exists('form input[name="title"][type="text"]')
      ->element_exists('form textarea[name=description]')
      ->element_exists('form input[type="submit"]');
}

# submit new
{
    sleep 1;
    my $data = $data[1];
    $t->ua->max_redirects(5);
    $t->post_form_ok('/questions/new/submit' => $data)
      ->status_is(200)
      ->text_is('#question h2' => $data->{title})
      ->text_is('.description' => $data->{description});
}

# show
{
    my $data = $data[0];
    $t->get_ok('/questions/1')
      ->status_is(200)
      ->text_is('#question h2' => $data->{title})
      ->text_is('.description' => $data->{description});

    # show (non-existent)
    $t->get_ok('/questions/0')
      ->status_is(500)
      ->text_is('head title' => 'Page not found');
}

# list
{
    my $num_questions = scalar @data;
    $t->get_ok('/questions')
      ->status_is(200)
      ->text_is('body h2' => 'Latest Questions')
      ->element_exists("#questions div:first-child h3 a[href=/questions/$num_questions]")
      # question order is from latest to earliest
      ->text_is("#questions div:first-child h3 a", $data[$#data]{title})
      ->text_is("#questions div:last-child h3 a", $data[0]{title});
}

done_testing();
