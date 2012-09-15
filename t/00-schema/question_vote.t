use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::DBIx::Class {force_drop_table => 1}, 'QuestionVote';

is_resultset QuestionVote;
is QuestionVote->count, 0, 'empty';

# create record
my %question_vote = (
    user_id => 1,
    question_id => 1,
    value => 1,
);
{
    fixtures_ok 'users';
    fixtures_ok 'questions';
    QuestionVote->create(\%question_vote);

    my $qv = QuestionVote->find(1, 1);
    isa_ok $qv->user, 'Grapevine::Schema::Result::User', 'user relationship';
    isa_ok $qv->question, 'Grapevine::Schema::Result::Question', 'question relationship';
    is $qv->value, $question_vote{value}, 'value 1';
    like $qv->created,  qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
}

# modify value
{
    my $qv = QuestionVote->find(1, 1);
    $qv->value(-1);
    $qv->update;

    $qv = QuestionVote->find(1, 1);
    is $qv->value, -1, 'value -1';

    like exception { $qv->value(0) }, qr/^value is required/, 'value is required';
    like exception { $qv->value(5) }, qr/^value must be either 1 or -1/, 'value is invalid';
}

# relationship
{
    my $qv = QuestionVote->find(1, 1);
    isa_ok $qv->user, 'Grapevine::Schema::Result::User', 'user relationship';
    isa_ok $qv->question, 'Grapevine::Schema::Result::Question', 'question relationship';
}

done_testing;
