#!/usr/bin/perl

use strict;
use warnings;

BEGIN {
    use File::Basename 'dirname';
    use File::Spec::Functions qw(catdir splitdir);
    my @base = (splitdir(dirname(__FILE__)), '..');
    my $lib = join('/', @base, 'lib');
    -e catdir(@base, 't') ? unshift(@INC, $lib) : push(@INC, $lib);
}

( defined $ENV{GV_DBNAME} ) || die "Environment variable 'GV_DBNAME' must be set";
( defined $ENV{GV_DBUSER} ) || die "Environment variable 'GV_DBUSER' must be set";
( defined $ENV{GV_DBPASS} ) || die "Environment variable 'GV_DBPASS' must be set";

require Grapevine::Schema;

my $dsn = "dbi:Pg:dbname=$ENV{GV_DBNAME}";
print "Deploying schema [$dsn] ...\n";

my $schema = Grapevine::Schema->connect(
    $dsn, $ENV{GV_DBUSER}, $ENV{GV_DBPASS}, {RaiseError => 1}
);

#$schema->create_ddl_dir(['PostgreSQL'], $schema->schema_version, '.');
$schema->deploy({ add_drop_table => 1 });

__END__

=head1 NAME

deploy_schema

=head1 USAGE

perl deploy_schema.pl

=cut
