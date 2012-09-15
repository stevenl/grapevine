use ExtUtils::MakeMaker;
WriteMakefile(
    MIN_PERL_VERSION => '5.010',
    BUILD_REQUIRES => {
        Test::More => '0.96',
        Test::Fatal => '0.008',
        Test::DBIx::Class => '0.30',
    },
    PREREQ_PM => {
        Class::Method::Modifiers => '1.08',
        Crypt::Eksblowfish::Bcrypt => '0.008',
        DBD::Pg => '2.18',
        DBIx::Class => '0.08120',
        Email::Valid => '0.15',
        Mojolicious => '3.02',
        Plack => '1.0000',
        Try::Tiny => '0.10',
    },
);
