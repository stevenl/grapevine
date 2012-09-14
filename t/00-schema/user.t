use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::DBIx::Class {force_drop_table => 1}, 'User';

is_resultset User;
is User->count, 0, 'empty';

# create record
my $user;
my %user = (
    username => 'johndoe',
    password => 'letmein',
    email => 'johndoe@example.com',
);

{
    User->create(\%user);

    $user = User->find(1);
    is_result $user;
    is_fields [qw( username email )],
        $user, [ @user{qw( username email )} ], 'user';

    like $user->created, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
}

# authenticate
{
    ok $user->password, 'password';
    ok $user->salt, 'salt';
    ok $user->authenticate( $user{password} ), 'authenticate';
    ok ! $user->authenticate('wrongpassword'), 'wrong password';
}

# data validation
# username
{
    %user = ( username => '', password => 'anything', email => 'anything@example.com' );
    like exception { User->new(\%user) },   qr/^username is required/, 'username is required';
    like exception { $user->username('') }, qr/^username is required/, 'username is required';

    %user = ( username => 'John_Doe-1.23', password => 'anything', email => 'anything@example.com' );
    ok User->new(\%user), 'username allowed characters';

    %user = ( username => 'John_Doe!-1.23', password => 'anything', email => 'anything@example.com' );
    like exception { User->new(\%user) }, qr/^username is invalid/, 'username disallowed characters';

    %user = ( username => 'johndoe', password => 'anything', email => 'anything@example.com' );
    like exception { User->new(\%user) }, qr/^username is not available/, 'username is not available';
}
# password
{
    %user = ( username => 'anything', password => '', email => 'anything@example.com' );
    like exception { User->new(\%user) },   qr/^password is required/, 'password is required';
    like exception { $user->password('') }, qr/^password is required/, 'password is required';
}
# email
{
    %user = ( username => 'anything', password => 'anything', email => '' );
    like exception { User->new(\%user) }, qr/^email is required/, 'email is required';
    like exception { $user->email('') }, qr/^email is required/, 'email is required';

    %user = ( username => 'anything', password => 'anything', email => 'invalid email address' );
    like exception { User->new(\%user) }, qr/^email is invalid/, 'email is invalid';

    like exception { $user->email('invalid email address') }, qr/^email is invalid/, 'email is invalid';
}

# relationships
{
    fixtures_ok 'deals';
    is $user->deals_rs->count, 2, 'deals relationship';
}

done_testing;
