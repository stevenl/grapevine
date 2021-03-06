package Grapevine::Schema::Result::Question;
use parent 'DBIx::Class::Core';

use strict;
use warnings;
use feature 'switch';

__PACKAGE__->load_components('+Grapevine::Schema::Component::Timestamp');

__PACKAGE__->table('question');

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
__PACKAGE__->has_many(answers => 'Grapevine::Schema::Result::Answer', 'question_id');
__PACKAGE__->has_many(votes => 'Grapevine::Schema::Result::QuestionVote', 'question_id');

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

sub sum_votes {
    my $self = shift;
    return $self->votes_rs->get_column('value')->sum || 0;
}

1;
