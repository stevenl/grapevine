use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::DBIx::Class {force_drop_table => 1}, 'Deal';

is_resultset Deal;
is Deal->count, 0, 'empty';

# create record
my %deal = (
    user_id => 1,
    title => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut purus orci, eu tristique nisl.',
    description => 'Praesent semper, tortor in vehicula ullamcorper, massa purus gravida nunc, vitae eleifend erat risus et libero. Nulla nisi lorem, vehicula et consequat in, cursus at metus. Aenean eleifend dictum ipsum a venenatis. Mauris pellentesque commodo arcu sit amet fermentum. Integer porta varius sem, eget blandit quam tempus a. Praesent condimentum tortor odio, ac mattis mauris. Cras iaculis ullamcorper interdum. Donec odio augue, vehicula nec rhoncus non, aliquet id ante. Nullam a malesuada nisl. Aliquam viverra tempor leo ut malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pretium quam et felis eleifend et rhoncus sapien tincidunt.',
);
{
    fixtures_ok 'users';
    Deal->create(\%deal);

    my $deal = Deal->find(1);
    is_fields [qw( title description )], $deal, [ @deal{qw(title description)} ];
    isa_ok $deal->user, 'Grapevine::Schema::Result::User', 'user relationship';

    like $deal->created,  qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
    like $deal->modified, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'modified';
    is $deal->created, $deal->modified, 'created == modified';
}

# modify title
{
    my $deal = Deal->find(1);
    my $last_modified = $deal->modified;
    sleep 1;

    my $title = 'Sed consectetur, neque ut lacinia vestibulum, arcu odio placerat eros, sit amet egestas risus quam vitae nibh.';
    $deal->title( $title );
    $deal->update;

    $deal = Deal->find(1);
    is $deal->title, $title, 'update title';
    ok $deal->modified gt $last_modified, 'modified updated';

    like exception { $deal->title('') }, qr/^title is required/, 'title is required';
}

# modify description
{
    my $deal = Deal->find(1);
    my $last_modified = $deal->modified;
    sleep 1;

    my $description = 'Quisque neque nulla, interdum eget aliquam sit amet, egestas a magna. Aenean quis risus arcu. Aliquam eu lorem felis, ut commodo libero. Morbi blandit, nisi vitae accumsan semper, arcu leo convallis ipsum, vel placerat eros est vel nunc. Curabitur facilisis sapien et nisi varius placerat. Nullam viverra lacus at nibh consequat quis dictum enim blandit. Vestibulum euismod tortor et urna tempor posuere. Aliquam ac purus non ligula blandit rutrum.';
    $deal->description( $description );
    $deal->update;

    $deal = Deal->find(1);
    is $deal->description, $description, 'update description';
    ok $deal->modified gt $last_modified, 'modified updated';
}

# description teaser
{
    my $description = 'Quisque neque nulla, interdum eget aliquam sit amet, egestas a magna.';

    my $deal = Deal->find(1);
    like $deal->description_teaser, qr/^$description.+ \.{3}$/, 'long teaser';

    $deal->description( $description );
    is $deal->description_teaser, $description, 'short teaser';
}

done_testing;
