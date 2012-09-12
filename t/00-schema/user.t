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

$user = $user_rs->new({ username => 'johndoe', password => 'notunique', email => 'notunique@example.com' });
like exception { $user->insert }, qr/violates unique constraint/, 'username must be unique';

done_testing();
