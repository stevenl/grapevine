package Grapevine::Schema::Result::QuestionVote;
use parent 'DBIx::Class::Core';

use strict;
use warnings;

__PACKAGE__->load_components('+Grapevine::Schema::Component::Timestamp');

__PACKAGE__->table('question_vote');

__PACKAGE__->add_columns(
    user_id => {
        data_type => 'serial',
        is_nullable => 0,
      },
    question_id => {
        data_type => 'serial',
        is_nullable => 0,
      },
    value => {
        data_type => 'smallint',
        is_nullable => 0,
      },
    created => {
        data_type => 'timestamp',
        is_nullable => 0,
        set_on_insert => 1,
      },
);

__PACKAGE__->set_primary_key(qw[ user_id question_id ]);

__PACKAGE__->belongs_to(user => 'Grapevine::Schema::Result::User', 'user_id');
__PACKAGE__->belongs_to(question => 'Grapevine::Schema::Result::Question', 'question_id');

sub store_column {
    my ($self, $col, $val) = @_;

    die "$col is required" if ! $val;

    if ($col eq 'value') {
        die 'value must be either 1 or -1' if $val != 1 && $val != -1;
    }

    $self->next::method($col, $val);
}

1;
