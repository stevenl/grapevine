use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::DBIx::Class {force_drop_table => 1}, 'Question';

is_resultset Question;
is Question->count, 0, 'empty';

# create record
my %question = (
    user_id => 1,
    title => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam ut purus orci, eu tristique nisl.',
    description => 'Praesent semper, tortor in vehicula ullamcorper, massa purus gravida nunc, vitae eleifend erat risus et libero. Nulla nisi lorem, vehicula et consequat in, cursus at metus. Aenean eleifend dictum ipsum a venenatis. Mauris pellentesque commodo arcu sit amet fermentum. Integer porta varius sem, eget blandit quam tempus a. Praesent condimentum tortor odio, ac mattis mauris. Cras iaculis ullamcorper interdum. Donec odio augue, vehicula nec rhoncus non, aliquet id ante. Nullam a malesuada nisl. Aliquam viverra tempor leo ut malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris pretium quam et felis eleifend et rhoncus sapien tincidunt.',
);
{
    fixtures_ok 'users';
    Question->create(\%question);

    my $question = Question->find(1);
    is_fields [qw( title description )], $question, [ @question{qw(title description)} ];
    isa_ok $question->user, 'Grapevine::Schema::Result::User', 'user relationship';

    like $question->created,  qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
    like $question->modified, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'modified';
    is $question->created, $question->modified, 'created == modified';
}

# modify title
{
    my $question = Question->find(1);
    my $last_modified = $question->modified;
    sleep 1;

    my $title = 'Sed consectetur, neque ut lacinia vestibulum, arcu odio placerat eros, sit amet egestas risus quam vitae nibh.';
    $question->title( $title );
    $question->update;

    $question = Question->find(1);
    is $question->title, $title, 'update title';
    ok $question->modified gt $last_modified, 'modified updated';

    like exception { $question->title('') }, qr/^title is required/, 'title is required';
}

# modify description
{
    my $question = Question->find(1);
    my $last_modified = $question->modified;
    sleep 1;

    my $description = 'Quisque neque nulla, interdum eget aliquam sit amet, egestas a magna. Aenean quis risus arcu. Aliquam eu lorem felis, ut commodo libero. Morbi blandit, nisi vitae accumsan semper, arcu leo convallis ipsum, vel placerat eros est vel nunc. Curabitur facilisis sapien et nisi varius placerat. Nullam viverra lacus at nibh consequat quis dictum enim blandit. Vestibulum euismod tortor et urna tempor posuere. Aliquam ac purus non ligula blandit rutrum.';
    $question->description( $description );
    $question->update;

    $question = Question->find(1);
    is $question->description, $description, 'update description';
    ok $question->modified gt $last_modified, 'modified updated';
}

# answers relationship
{
    my $question = Question->find(1);
    is $question->answers_rs->result_class, 'Grapevine::Schema::Result::Answer', 'answers relationship';
    is $question->answers_rs->count, 0;

    fixtures_ok 'answers';
    is $question->answers_rs->count, 2;
}

done_testing;
