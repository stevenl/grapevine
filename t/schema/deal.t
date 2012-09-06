use strict;
use warnings;

use Test::More tests => 18;
use Test::Fatal;

BEGIN { use_ok 'Grapevine::Schema' }

my $schema = Grapevine::Schema->connect('dbi:Pg:dbname=grapevinetest', 'postgres', 'P@ssw0rd', {RaiseError => 1});
isa_ok( $schema, 'DBIx::Class::Schema' );
my $dbh = $schema->storage->dbh;
ok( $dbh->{Active}, 'connect' );

$schema->deploy({ add_drop_table => 1 });

my $deal_rs = $schema->resultset('Deal');
isa_ok( $deal_rs, 'DBIx::Class::ResultSet' );
is( $deal_rs->count, 0, 'empty' );

# create record
my $deal;
my $rec;
{
    my %data = (
        title => 'Cheap Cheap',
        description => 'For only $2',
    );
    $deal = $deal_rs->new(\%data);
    $deal->insert;

    my $rec = $dbh->selectrow_hashref('select * from deal');
    isa_ok( $rec, 'HASH', 'inserted' );
    is( $rec->{deal_id}, 1, 'deal id' );
    is( $rec->{title}, $data{title}, 'title' );
    is( $rec->{description}, $data{description}, 'description' );
    isnt( $rec->{created},  undef, 'created' );
    isnt( $rec->{modified}, undef, 'modified' );
    is( $rec->{deleted}, undef, 'deleted' );
    is( $rec->{created}, $rec->{modified}, 'created == modified' );
    is( $deal->created, $rec->{created}, 'timestamp format' );
}

# modify record
{
    my %data = (
        title => 'Even Cheaper',
        description => 'Now for only $1',
    );

    my $last_modified = $rec->{modified};
    sleep 1;
    $deal->title( $data{title} );
    $deal->update;

    $rec = $dbh->selectrow_hashref('select * from deal');
    is( $rec->{title}, $data{title}, 'update title' );
    isnt( $rec->{modified}, $last_modified, 'modified' );

    $last_modified = $rec->{modified};
    sleep 1;
    $deal->description( $data{description} );
    $deal->update;

    $rec = $dbh->selectrow_hashref('select * from deal');
    is( $rec->{description}, $data{description}, 'update description' );
    isnt( $rec->{modified}, $last_modified, 'modified' );
}
