package Grapevine::Deals;
use Mojo::Base 'Mojolicious::Controller';

sub enter_new {
    my $self = shift;

    if ( ! $self->session('user') ) {
        $self->flash(message => 'You must log in to post a deal');
        $self->session(url => 'new_deal');
        return $self->redirect_to('login');
    }

    $self->render('deals/new');
}

sub submit_new {
    my $self = shift;

    my $new_deal = $self->db->resultset('Deal')->create( {
        title       => $self->param('title'),
        description => $self->param('description'),
    } );

    # show the newly submitted deal
    $self->redirect_to('deal', deal_id => $new_deal->id);
}

sub show {
    my $self = shift;

    my $deal_id = $self->param('deal_id');
    my $deal = $self->db->resultset('Deal')->find($deal_id);

    $self->render_not_found if ! defined $deal;

    $self->render('deals/show', deal => $deal);
}

sub list {
    my $self = shift;

    my @deals = $self->db->resultset('Deal')->search(
        undef, { order_by => { -desc => 'created'} }
    );

    $self->stash(
        title => 'Latest Deals',
        deals => \@deals
    );
    $self->render('deals/list');
}

1;
