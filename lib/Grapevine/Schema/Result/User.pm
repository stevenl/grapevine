package Grapevine::Schema::Result::User;
use parent 'DBIx::Class::Core';

use Class::Method::Modifiers;
use Crypt::Eksblowfish::Bcrypt 'bcrypt_hash';

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

sub store_column {
    my ($self, $col, $val) = @_;

    # store password as encrypted hash
    if ($col eq 'password') {
        # generate and store the salt for authentication
        my $salt = $self->generate_salt;
        $self->salt( $salt );

        $val = $self->bcrypt($val, $salt);
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

