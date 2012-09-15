package Grapevine::Deals;
use Mojo::Base 'Mojolicious::Controller';

sub enter_new {
    my $self = shift;

    $self->stash(title => 'Enter a New Deal');
    $self->render('deals/new');
}

sub submit_new {
    my $self = shift;

    my $new_deal = $self->db->resultset('Deal')->create( {
        title       => $self->param('title'),
        description => $self->param('description'),
    } );

    # show the newly submitted deal
    my $deal_id = $new_deal->id;
    $self->redirect_to("/deals/$deal_id");
}

sub show {
    my $self = shift;

    my $deal_id = $self->param('deal_id');
    my $deal = $self->db->resultset('Deal')->find($deal_id);

    $self->render_not_found if ! defined $deal;

    $self->stash(
        deal => $deal,
        title => $deal->title,
    );
    $self->render('deals/show')
}

sub list {
    my $self = shift;

    $self->stash(title => 'Latest Deals');

    my @deals = $self->db->resultset('Deal')->search(
        undef, { order_by => { -desc => 'created'} }
    );
    $self->stash(deals => \@deals);

    $self->render('deals/list');
}

1;
