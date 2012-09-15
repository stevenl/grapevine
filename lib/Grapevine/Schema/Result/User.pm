package Grapevine::Schema::Result::User;
use parent 'DBIx::Class::Core';

use strict;
use warnings;
use feature 'switch';

use Crypt::Eksblowfish::Bcrypt 'bcrypt_hash';
use Email::Valid;

my %BCRYPT_SETTINGS = (
    key_nul => 1,
    cost => 6,
);

__PACKAGE__->load_components('+Grapevine::Schema::Component::Timestamp');

__PACKAGE__->table('user');

__PACKAGE__->add_columns(
    id => {
        data_type => 'serial',
        is_nullable => 0,
        is_auto_increment => 1,
      },
    username => {
        data_type => 'varchar',
        size      => 60,
        is_nullable => 0,
      },
    password => {
        data_type => 'bytea',
        is_nullable => 0,
      },
    salt => {
        data_type => 'bytea',
        is_nullable => 0,
      },
    email => {
        data_type => 'varchar',
        size      => 127,
        is_nullable => 0,
      },
    created => {
        data_type => 'timestamp',
        is_nullable => 0,
        set_on_insert => 1,
      },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['username']); # with btree index

__PACKAGE__->has_many(deals => 'Grapevine::Schema::Result::Deal', 'user_id');
__PACKAGE__->has_many(questions => 'Grapevine::Schema::Result::Question', 'user_id');
__PACKAGE__->has_many(answers => 'Grapevine::Schema::Result::Answer', 'user_id');
__PACKAGE__->has_many(question_votes => 'Grapevine::Schema::Result::QuestionVote', 'user_id');

sub store_column {
    my ($self, $col, $val) = @_;

    for ($col) {
        when ('username') {
            die 'username is required'      if ! $val;
            die 'username is invalid'       if $val !~ /^[\w\.\-]+$/;
            die 'username is not available' if $self->result_source->resultset->find({username => $val})
        }
        when ('password') {
            die 'password is required' if ! $val;

            # generate and store salt
            my $salt = $self->generate_salt;
            $self->salt($salt);
            # encrypt password
            $val = $self->bcrypt($val, $salt);
        }
        when ('email') {
            die 'email is required' if ! $val;
            die 'email is invalid'  if ! Email::Valid->address($val);
        }
    }

    return $self->next::method($col, $val);
}

sub authenticate {
    my ($self, $password) = @_;

    $password = $self->bcrypt($password, $self->salt);
    return $self->password eq $password;
}

sub generate_salt {
    # bcrypt expects 16 octets of salt
    return join '', map { chr int rand 256 } 1 .. 16;
}

sub bcrypt {
    my ($self, $string, $salt) = @_;

    my %settings = ( %BCRYPT_SETTINGS, salt => $salt );
    return bcrypt_hash(\%settings, $string);
}

1;
