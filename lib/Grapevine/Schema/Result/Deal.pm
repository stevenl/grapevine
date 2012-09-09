package Grapevine::Schema::Result::Deal;
use parent 'DBIx::Class::Core';

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

sub description_teaser {
    my $self = shift;

    my $description = $self->description;

    $description = sprintf "%.${TEASER_LENGTH}s ...", $description
        if length $description > $TEASER_LENGTH;

    return $description;
}

1;
