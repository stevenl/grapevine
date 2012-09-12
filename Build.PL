use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Grapevine',
    license             => 'perl',
    dist_author         => q{Steven Lee <stevenl@cpan.org>},
    dist_version_from   => 'lib/Grapevine.pm',
    configure_requires  => {
        Module::Build => '0.40',
    },
    build_requires => {
        Test::More => '0.96',
        Test::Fatal => '0.008',
        Test::DBIx::Class => '0.30',
    },
    requires => {
        perl => '5.010',
        Class::Method::Modifiers => '1.08',
        Crypt::Eksblowfish::Bcrypt => '0.008',
        DBIx::Class => '0.08120',
        Email::Valid => '0.15',
        Mojolicious => '3.02',
        Try::Tiny => '0.10',
    },
    create_makefile_pl => 'traditional',
    meta_merge => {
        resources => {
            #homepage   => 'http://search.cpan.org/dist/Grapevine/',
            bugtracker => 'http://github.com/stevenl/grapevine/issues',
            repository => 'http://github.com/stevenl/grapevine',
        }
    },
    add_to_cleanup      => [ 'Grapevine-*' ],
);

$builder->create_build_script();
