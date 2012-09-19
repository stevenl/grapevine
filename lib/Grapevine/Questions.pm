package Grapevine::Questions;
use Mojo::Base 'Mojolicious::Controller';

sub enter_new {
    my $self = shift;

    if ( ! $self->session('user') ) {
        $self->flash(message => 'You must log in to ask a question');
        $self->session(url => 'ask_question');
        return $self->redirect_to('login');
    }

    $self->render('questions/ask');
}

sub submit_new {
    my $self = shift;

    my $new_question = $self->db->resultset('Question')->create( {
        title       => $self->param('title'),
        description => $self->param('description'),
    } );

    # show the newly submitted question
    $self->redirect_to('question', question_id => $new_question->id);
}

sub show {
    my $self = shift;

    my $question_id = $self->param('question_id');
    my $question = $self->db->resultset('Question')->find($question_id);

    $self->render_not_found if ! defined $question;

    $self->render('questions/show', question => $question);
}

sub list {
    my $self = shift;

    $self->stash(title => 'Latest Questions');

    my @questions = $self->db->resultset('Question')->search(
        undef, { order_by => { -desc => 'created'} }
    );

    $self->render('questions/list', questions => \@questions);
}

1;
