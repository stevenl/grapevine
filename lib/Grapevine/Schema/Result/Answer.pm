package Grapevine::Schema::Result::Answer;
use parent 'DBIx::Class::Core';

use strict;
use warnings;

__PACKAGE__->load_components('+Grapevine::Schema::Component::Timestamp');

__PACKAGE__->table('answer');

__PACKAGE__->add_columns(
    id => {
        data_type => 'serial',
        is_nullable => 0,
        is_auto_increment => 1,
      },
    user_id => {
        data_type => 'serial',
        is_nullable => 0,
      },
    question_id => {
        data_type => 'serial',
        is_nullable => 0,
      },
    content => {
        data_type => 'text',
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
__PACKAGE__->belongs_to(question => 'Grapevine::Schema::Result::Question', 'question_id');

sub store_column {
    my ($self, $col, $val) = @_;

    die 'content is required' if $col eq 'content' && ! $val;

    return $self->next::method($col, $val);
}

1;
