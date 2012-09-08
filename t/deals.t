use strict;
use warnings;

use Test::More;
use Test::Mojo;
use File::Slurp 'slurp';
use Grapevine::Schema;

my $t = Test::Mojo->new('Grapevine');

# create database
my $schema = Grapevine::Schema->connect('dbi:Pg:dbname=grapevinetest', 'postgres', 'P@ssw0rd', {RaiseError => 1});
$schema->deploy({ add_drop_table => 1 });
$t->app->schema($schema);

# populate database
my @data; eval slurp \*DATA;
$t->app->schema->resultset('Deal')->new($data[0])->insert;
sleep 1;

# new
{
    $t->get_ok('/deals/new')->status_is(200);
    my $form = $t->ua->get('/deals/new')->res->dom->at('form');
    ok( $form, 'has form' );
    is( $form->{method}, 'post', 'is post form' );
    is( $form->{action}, '/deals/new/submit', 'submit action' );

    my $title = $form->p->[0]->input;
    is( $title->{name}, 'title', 'has title input' );
    is( $title->{type}, 'text', 'is text input' );

    is( $form->p->[1]->textarea->{name}, 'description', 'has description textarea' );
}

# submit new
{
    my $data = $data[1];
    $t->ua->max_redirects(5);
    $t->post_form_ok('/deals/new/submit' => $data)
      ->status_is(200)
      ->text_is('#deal h2' => $data->{title})
      ->text_is('.description' => $data->{description});
}

# show
{
    my $data = $data[0];
    $t->get_ok('/deals/1')
      ->status_is(200)
      ->text_is('#deal h2' => $data->{title})
      ->text_is('.description' => $data->{description});

    # show (non-existent)
    $t->get_ok('/deals/0')
      ->status_is(500)
      ->text_is('head title' => 'Page not found');
}

# list
{
    $t->get_ok('/deals')
      ->status_is(200)
      ->text_is('body h2' => 'Latest Deals');

    my $deals = $t->ua->get('/deals')->res->dom->at('#deals');

    my $deal = $deals->div->[0];
    is( $deal->h3->all_text, $data[$#data]{title}, 'list title' );
    is( $deal->h3->a->{href}, '/deals/'.scalar(@data), 'list title with hyperlinked' );

    my $description = $deal->p->text;
    is( length $description, 254, 'teaser trimmed' );
    ok( $description =~ / \.{3}$/, 'teaser with ellipses' );

    foreach (0 .. $#data) {
        is( $deals->div->[$_]->h3->all_text, $data[ $#data - $_ ]{title}, "list order $_" );
    }
}

done_testing();

__DATA__
@data = (
  {
    title => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut purus orci, eu tristique nisl.',
    description => 'Praesent semper, tortor in vehicula ullamcorper, massa purus gravida nunc, vitae eleifend erat risus et libero. Nulla nisi lorem, vehicula et consequat in, cursus at metus. Aenean eleifend dictum ipsum a venenatis. Mauris pellentesque commodo arcu sit amet fermentum. Integer porta varius sem, eget blandit quam tempus a. Praesent condimentum tortor odio, ac mattis mauris. Cras iaculis ullamcorper interdum. Donec odio augue, vehicula nec rhoncus non, aliquet id ante. Nullam a malesuada nisl. Aliquam viverra tempor leo ut malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pretium quam et felis eleifend et rhoncus sapien tincidunt.',
  }, {
    title => 'Sed consectetur, neque ut lacinia vestibulum, arcu odio placerat eros, sit amet egestas risus quam vitae nibh.',
    description => 'Quisque neque nulla, interdum eget aliquam sit amet, egestas a magna. Aenean quis risus arcu. Aliquam eu lorem felis, ut commodo libero. Morbi blandit, nisi vitae accumsan semper, arcu leo convallis ipsum, vel placerat eros est vel nunc. Curabitur facilisis sapien et nisi varius placerat. Nullam viverra lacus at nibh consequat quis dictum enim blandit. Vestibulum euismod tortor et urna tempor posuere. Aliquam ac purus non ligula blandit rutrum.',
  }
);
