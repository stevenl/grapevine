use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::DBIx::Class {force_drop_table => 1}, 'Answer';

is_resultset Answer;
is Answer->count, 0, 'empty';

# create record
my %answer = (
    user_id => 1,
    question_id => 1,
    content => 'Proin lobortis posuere nisl eu sollicitudin. Curabitur ligula nisl, mattis vitae aliquet adipiscing, tincidunt ac velit.'
);
{
    fixtures_ok 'users';
    fixtures_ok 'questions';
    Answer->create(\%answer);

    my $answer = Answer->find(1);
    is $answer->content, $answer{content}, 'content';
    isa_ok $answer->user, 'Grapevine::Schema::Result::User', 'user relationship';
    isa_ok $answer->question, 'Grapevine::Schema::Result::Question', 'question relationship';

    like $answer->created,  qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
    like $answer->modified, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'modified';
    is $answer->created, $answer->modified, 'created == modified';
}

# modify content
{
    my $answer = Answer->find(1);
    my $last_modified = $answer->modified;
    sleep 1;

    my $content = 'Aenean a tortor commodo turpis pharetra egestas. Nullam fringilla scelerisque augue, eu dictum nibh eleifend id.';
    $answer->content( $content );
    $answer->update;

    $answer = Answer->find(1);
    is $answer->content, $content, 'update content';
    ok $answer->modified gt $last_modified, 'modified updated';

    like exception { $answer->content('') }, qr/^content is required/, 'content is required';
}

done_testing;
