use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::DBIx::Class {force_drop_table => 1}, 'User';

is_resultset User;
is User->count, 0, 'empty';

# create record
my $user;
my %data = (
    username => 'johndoe',
    password => 'letmein',
    email => 'johndoe@example.com',
);
{
    User->new(\%data)->insert;

    $user = User->find(1);
    is_result $user;
    is_fields [qw( username email )],
        $user, [ @data{qw( username email )} ], 'user';

    like $user->created, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
}

# authenticate
{
    ok $user->password, 'password';
    ok $user->salt, 'salt';
    ok $user->authenticate( $data{password} ), 'authenticate';
    ok ! $user->authenticate('wrongpassword'), 'wrong password';
}

# data validation
# username
{
    %data = ( username => '', password => 'anything', email => 'anything@example.com' );
    like exception { User->new(\%data) },   qr/^username is required/, 'username is required';
    like exception { $user->username('') }, qr/^username is required/, 'username is required';

    %data = ( username => 'John_Doe-1.23', password => 'anything', email => 'anything@example.com' );
    ok User->new(\%data), 'username allowed characters';

    %data = ( username => 'John_Doe!-1.23', password => 'anything', email => 'anything@example.com' );
    like exception { User->new(\%data) }, qr/^username is invalid/, 'username disallowed characters';

    %data = ( username => 'johndoe', password => 'anything', email => 'anything@example.com' );
    like exception { User->new(\%data) }, qr/^username is not available/, 'username is not available';
}
# password
{
    %data = ( username => 'anything', password => '', email => 'anything@example.com' );
    like exception { User->new(\%data) },   qr/^password is required/, 'password is required';
    like exception { $user->password('') }, qr/^password is required/, 'password is required';
}
# email
{
    %data = ( username => 'anything', password => 'anything', email => '' );
    like exception { User->new(\%data) }, qr/^email is required/, 'email is required';
    like exception { $user->email('') }, qr/^email is required/, 'email is required';

    %data = ( username => 'anything', password => 'anything', email => 'invalid email address' );
    like exception { User->new(\%data) }, qr/^email is invalid/, 'email is invalid';

    like exception { $user->email('invalid email address') }, qr/^email is invalid/, 'email is invalid';
}

done_testing;
