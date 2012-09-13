use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN { use_ok 'Grapevine::Schema' }

my $schema = Grapevine::Schema->connect('dbi:Pg:dbname=grapevinetest', 'postgres', 'P@ssw0rd', {RaiseError => 1, quote_char => '"'});
my $dbh = $schema->storage->dbh;
$schema->deploy({ add_drop_table => 1 });
{
    isa_ok $schema, 'DBIx::Class::Schema';
    ok $dbh->{Active}, 'connect';
}

my $user_rs = $schema->resultset('User');
{
    isa_ok $user_rs, 'DBIx::Class::ResultSet';
    is $user_rs->count, 0, 'empty';
}

# create record
my %data = (
    username => 'johndoe',
    password => 'letmein',
    email => 'johndoe@example.com',
);

my $user = $user_rs->new(\%data);
$user->insert;
{
    my $rec = $dbh->selectrow_hashref('select * from "user"');
    is $rec->{id}, 1, 'user id';
    is $rec->{username}, $data{username}, 'username';
    isnt $rec->{password}, undef, 'password';
    isnt $rec->{salt}, undef, 'salt';
    is $rec->{email}, $data{email}, 'email';
    like $rec->{created}, qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/, 'created';
}

# authenticate
{
    ok $user->authenticate( $data{password} ), 'authenticate';
    ok ! $user->authenticate('LetMeIn'), 'wrong password';
}

# data validation
# username
{
    like(
        exception { $user_rs->new({ username => '', password => 'anything', email => 'anything@example.com' }) },
        qr/^username is required/, 'username is required'
    );
    like exception { $user->username('') }, qr/^username is required/, 'username is required';

    ok $user_rs->new({ username => 'John_Doe-1.23', password => 'anything', email => 'anything@example.com' }), 'username allowed characters';
    like(
        exception { $user_rs->new({ username => 'John_Doe!-1.23', password => 'anything', email => 'anything@example.com' }) },
        qr/^username is invalid/, 'username disallowed characters'
    );
    like(
        exception { $user_rs->new({ username => 'johndoe', password => 'anything', email => 'anything@example.com' }) },
        qr/^username is not available/, 'username is not available'
    );
}
# password
{
    like(
        exception { $user_rs->new({ username => 'anything', password => '', email => 'anything@example.com' }) },
        qr/^password is required/, 'password is required'
    );
    like exception { $user->password('') }, qr/^password is required/, 'password is required';
}
# email
{
    like(
        exception { $user_rs->new({ username => 'anything', password => 'anything', email => '' }) },
        qr/^email is required/, 'email is required'
    );
    like exception { $user->email('') }, qr/^email is required/, 'email is required';
    like(
        exception { $user_rs->new({ username => 'anything', password => 'anything', email => 'invalid email address' }) },
        qr/^email is invalid/, 'email is invalid'
    );
    like exception { $user->email('invalid email address') }, qr/^email is invalid/, 'email is invalid';
}

done_testing;
