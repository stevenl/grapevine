package Grapevine::Schema::Component::Timestamp;
use parent 'DBIx::Class';

use Time::Piece;

our $TIMESTAMP_FORMAT = '%Y-%m-%d %H:%M:%S';

sub current_timestamp {
    localtime()->strftime($TIMESTAMP_FORMAT);
}

__PACKAGE__->mk_classdata( set_on_insert => [] );
__PACKAGE__->mk_classdata( set_on_update => [] );

sub add_columns {
    my $self = shift;
    my @cols = @_;

    my @set_on_insert;
    my @set_on_update;

    while (my $column_name = shift @cols) {
        my $info = ref $cols[0] ? shift @cols : {};
        push @set_on_insert, $column_name if $info->{set_on_insert};
        push @set_on_update, $column_name if $info->{set_on_update};
    }
    $self->set_on_insert(\@set_on_insert);
    $self->set_on_update(\@set_on_update);

    return $self->next::method(@_);
}

sub insert {
    my $self = shift;

    my $timestamp = current_timestamp();

    foreach my $column_name ( @{$self->set_on_insert} ) {
        next if defined $self->get_column($column_name);

        my $accessor = $self->column_info($column_name)->{accessor} || $column_name;
        $self->$accessor($timestamp);
    }

    return $self->next::method(@_);
}

sub update {
    my $self = shift;

    $self->set_inflated_columns(@_) if @_;

    my %dirty = $self->get_dirty_columns;
    my $timestamp = current_timestamp();

    foreach my $column_name ( @{$self->set_on_update} ) {
        next if exists $dirty{$column_name};

        my $accessor = $self->column_info($column_name)->{accessor} || $column_name;
        $self->$accessor($timestamp);

        $dirty{$column_name} = undef;
    }

    return $self->next::method;
}

1;
