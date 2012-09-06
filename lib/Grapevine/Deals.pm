package Grapevine::Deals;
use Mojo::Base 'Mojolicious::Controller';

sub show {
    my $self = shift;

    my $deal_id = $self->param('dealid');
    my $deal = $self->db->resultset('Deal')->find($deal_id);

    $self->render_not_found if ! defined $deal;

    $self->stash(
        deal => $deal,
        title => $deal->title,
    );
    $self->render('deals/show')
}

1;
