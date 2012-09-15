use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::DBIx::Class {force_drop_table => 1}, 'User';

is_resultset User;
is User->count, 0, 'empty';

# create record
{
    my %user = (
        username => 'johndoe',
        password => 'letmein',
        email => 'johndoe@example.com',
    );
    User->create(\%user);

    my $user = User->find(1);
    is_result $user;
    is_fields [qw( username email )],
        $user, [ @user{qw( username email )} ], 'user';

    # authenticate
    ok $user->password, 'password';
    ok $user->salt, 'salt';
    ok $user->authenticate( $user{password} ), 'authenticate';
    ok ! $user->authenticate('wrongpassword'), 'wrong password';

    like $user->created, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
}

# validate username
{
    my $user = User->find(1);
    $user->username('janedoe');
    $user->update;

    $user = User->find(1);
    is $user->username, 'janedoe', 'modify username';

    ok $user->username('John_Doe-1.23'), 'username allowed characters';
    like exception { $user->username('John_Doe!-1.23') }, qr/^username is invalid/, 'username disallowed characters';
    like exception { $user->username('') }, qr/^username is required/, 'username is required';
}

# validate password
{
    my $user = User->find(1);
    my $old_password = $user->password;
    my $old_salt = $user->salt;

    $user->password('letmeinagain');
    $user->update;

    $user = User->find(1);
    isnt $user->password, $old_password, 'modify password';
    isnt $user->salt, $old_salt, 'updated salt';
    ok $user->authenticate('letmeinagain'), 'authenticate';
    ok ! $user->authenticate('letmein'), 'wrong password';

    my %user1 = ( username => 'janedoe', password => 'anything', email => 'anything@example.com' );
    like exception { User->new(\%user1) }, qr/^username is not available/, 'username is not available';

    like exception { $user->password('') }, qr/^password is required/, 'password is required';
}

# validate email
{
    my $user = User->find(1);
    $user->email('janedoe@example.com');
    $user->update;

    $user = User->find(1);
    is $user->email, 'janedoe@example.com', 'modify email';

    like exception { $user->email('') }, qr/^email is required/, 'email is required';
    like exception { $user->email('invalid email address') }, qr/^email is invalid/, 'email is invalid';
}

# relationship deals
{
    my $user = User->find(1);
    is $user->deals_rs->result_class, 'Grapevine::Schema::Result::Deal', 'deals relationship';
    is $user->deals_rs->count, 0;

    fixtures_ok 'deals';
    is $user->deals_rs->count, 2;
}

# relationship questions
{
    my $user = User->find(1);
    is $user->questions_rs->result_class, 'Grapevine::Schema::Result::Question', 'questions relationship';
    is $user->questions_rs->count, 0;

    fixtures_ok 'questions';
    is $user->questions_rs->count, 2;
}

# relationship answers
{
    my $user = User->find(1);
    is $user->answers_rs->result_class, 'Grapevine::Schema::Result::Answer', 'answers relationship';
    is $user->answers_rs->count, 0;

    fixtures_ok 'answers';
    is $user->answers_rs->count, 2;
}

# relationship question votes
{
    my $user = User->find(1);
    is $user->questions_voted_rs->result_class, 'Grapevine::Schema::Result::QuestionVote', 'questions_voted relationship';
    is $user->question_votes_rs->count, 0;

    fixtures_ok 'question_votes';
    is $user->question_votes_rs->count, 2;
}

done_testing;
