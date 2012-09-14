package Grapevine::Schema::Result::Deal;
use parent 'DBIx::Class::Core';

use strict;
use warnings;
use feature 'switch';

my $TEASER_LENGTH = 250;

__PACKAGE__->load_components('+Grapevine::Schema::Component::Timestamp');

__PACKAGE__->table('deal');

__PACKAGE__->add_columns(
    id => {
        data_type => 'serial',
        is_nullable => 0,
        is_auto_increment => 1,
      },
    title => {
        data_type => 'varchar',
        size      => 255,
        is_nullable => 0,
      },
    description => {
        data_type => 'text',
        is_nullable => 1,
      },
    user_id => {
        data_type => 'serial',
        is_nullable => 0,
      },
    created => {
        data_type => 'timestamp',
        is_nullable => 0,
        set_on_insert => 1,
      },
    modified => {
        data_type => 'timestamp',
        is_nullable => 0,
        set_on_insert => 1,
        set_on_update => 1,
      },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(user => 'Grapevine::Schema::Result::User', 'user_id');

sub store_column {
    my ($self, $col, $val) = @_;

    for ($col) {
        when ('title') {
            die 'title is required' if ! $val;
        }
        when ('user_id') {
            die 'user_id is required' if ! $val;
        }
    }

    return $self->next::method($col, $val);
}

sub description_teaser {
    my $self = shift;

    my $description = $self->description;

    $description = sprintf "%.${TEASER_LENGTH}s ...", $description
        if length $description > $TEASER_LENGTH;

    return $description;
}

1;
