package Grapevine::Deals;
use Mojo::Base 'Mojolicious::Controller';

sub enter_new {
    my $self = shift;

    $self->stash(title => 'Enter a New Deal');
    $self->render('deals/new');
}

sub submit_new {
    my $self = shift;

    my $new_deal = $self->db->resultset('Deal')->new( {
        title       => $self->param('title'),
        description => $self->param('description'),
    } );
    $new_deal->insert;

    # show the newly submitted deal
    my $deal_id = $new_deal->deal_id;
    $self->redirect_to("/deals/$deal_id");
}

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
