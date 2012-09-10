use strict;
use warnings;

use Test::More tests => 20;
use Test::Fatal;

BEGIN { use_ok 'Grapevine::Schema' }

my $schema = Grapevine::Schema->connect('dbi:Pg:dbname=grapevinetest', 'postgres', 'P@ssw0rd', {RaiseError => 1});
my $dbh = $schema->storage->dbh;
$schema->deploy({ add_drop_table => 1 });
{
    isa_ok $schema, 'DBIx::Class::Schema';
    ok $dbh->{Active}, 'connect';
}

my $deal_rs = $schema->resultset('Deal');
{
    isa_ok $deal_rs, 'DBIx::Class::ResultSet';
    is $deal_rs->count, 0, 'empty';
}

# create record
my %data = (
    title => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut purus orci, eu tristique nisl.',
    description => 'Praesent semper, tortor in vehicula ullamcorper, massa purus gravida nunc, vitae eleifend erat risus et libero. Nulla nisi lorem, vehicula et consequat in, cursus at metus. Aenean eleifend dictum ipsum a venenatis. Mauris pellentesque commodo arcu sit amet fermentum. Integer porta varius sem, eget blandit quam tempus a. Praesent condimentum tortor odio, ac mattis mauris. Cras iaculis ullamcorper interdum. Donec odio augue, vehicula nec rhoncus non, aliquet id ante. Nullam a malesuada nisl. Aliquam viverra tempor leo ut malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pretium quam et felis eleifend et rhoncus sapien tincidunt.',
);
my $deal = $deal_rs->new(\%data);
$deal->insert;
{
    my $rec = $dbh->selectrow_hashref('select * from deal');
    isa_ok $rec, 'HASH', 'inserted';
    is $rec->{id}, 1, 'deal id';
    is $rec->{title}, $data{title}, 'title';
    is $rec->{description}, $data{description}, 'description';

    isnt $rec->{created},  undef, 'created';
    isnt $rec->{modified}, undef, 'modified';
    is $rec->{deleted}, undef, 'deleted';
    is $rec->{created}, $rec->{modified}, 'created == modified';
    is $deal->created, $rec->{created}, 'timestamp format';
}

# modify title
my $title = 'Sed consectetur, neque ut lacinia vestibulum, arcu odio placerat eros, sit amet egestas risus quam vitae nibh.';
my $last_modified = $deal->modified;
sleep 1;
$deal->title( $title );
$deal->update;
{
    my $rec = $dbh->selectrow_hashref('select * from deal');
    is $rec->{title}, $title, 'update title';
    isnt $rec->{modified}, $last_modified, 'modified';
}

# modify description
my $description = 'Quisque neque nulla, interdum eget aliquam sit amet, egestas a magna. Aenean quis risus arcu. Aliquam eu lorem felis, ut commodo libero. Morbi blandit, nisi vitae accumsan semper, arcu leo convallis ipsum, vel placerat eros est vel nunc. Curabitur facilisis sapien et nisi varius placerat. Nullam viverra lacus at nibh consequat quis dictum enim blandit. Vestibulum euismod tortor et urna tempor posuere. Aliquam ac purus non ligula blandit rutrum.';
$last_modified = $deal->modified;
sleep 1;
$deal->description( $description );
$deal->update;
{
    my $rec = $dbh->selectrow_hashref('select * from deal');
    is $rec->{description}, $description, 'update description';
    isnt $rec->{modified}, $last_modified, 'modified';
}

# teaser
my $description = 'Quisque neque nulla, interdum eget aliquam sit amet, egestas a magna.';
my $long_teaser = $deal->description_teaser;
$deal->description( $description );
{
    like $long_teaser, qr/^$description.+ \.{3}$/, 'long teaser';
    is $deal->description_teaser, $description, 'short teaser';
}
