use strict;
use warnings;

use Test::More;
use Test::Mojo;
use File::Slurp 'slurp';
use Grapevine::Schema;

# create and populate database
my $schema = Grapevine::Schema->connect('dbi:Pg:dbname=grapevinetest', 'postgres', 'P@ssw0rd', {RaiseError => 1});
$schema->deploy({ add_drop_table => 1 });

my $t = Test::Mojo->new('Grapevine');
$t->app->schema($schema);

my %data; eval slurp \*DATA;
my $deal = $t->app->schema->resultset('Deal')->new(\%data)->insert;

# show
$t->get_ok('/deals/1')
  ->status_is(200)
  ->text_is('#deal h2' => $data{title})
  ->text_is('.description' => $data{description});

# show (non-existent)
$t->get_ok('/deals/0')
  ->status_is(500)
  ->text_is('head title' => 'Page not found');

done_testing();

__DATA__
%data = (
    title => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut purus orci, eu tristique nisl.',
    description => 'Praesent semper, tortor in vehicula ullamcorper, massa purus gravida nunc, vitae eleifend erat risus et libero. Nulla nisi lorem, vehicula et consequat in, cursus at metus. Aenean eleifend dictum ipsum a venenatis. Mauris pellentesque commodo arcu sit amet fermentum. Integer porta varius sem, eget blandit quam tempus a. Praesent condimentum tortor odio, ac mattis mauris. Cras iaculis ullamcorper interdum. Donec odio augue, vehicula nec rhoncus non, aliquet id ante. Nullam a malesuada nisl. Aliquam viverra tempor leo ut malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pretium quam et felis eleifend et rhoncus sapien tincidunt.',
);
