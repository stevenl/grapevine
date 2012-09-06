package Grapevine::Schema::Result::Deal;
use parent 'DBIx::Class::Core';

use Const::Fast;
use Time::Piece 'localtime';

const my $TIMESTAMP_FORMAT => '%Y-%m-%d %H:%M:%S';
const my @MODIFIABLE_COLUMNS => qw( title description );
sub now { localtime()->strftime($TIMESTAMP_FORMAT) }

__PACKAGE__->table('deal');

__PACKAGE__->add_columns(
    deal_id => {
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
      },
    modified => {
        data_type => 'timestamp',
        is_nullable => 0,
      },
);

__PACKAGE__->set_primary_key('deal_id');

sub new {
    my $class = shift;
    my $self = $class->next::method(@_);

    # set created and modified timestamps
    my $now = now();
    $self->created($now);
    $self->modified($now);

    return $self;
}

# set modified timestamp whenever a column value is changed
sub store_column {
    my ($self, $name, $value) = @_;

    # set the modified timestamp
    $self->modified( now() ) if grep {$name eq $_} @MODIFIABLE_COLUMNS;

    $self->next::method($name, $value);
    return;
}

1;
