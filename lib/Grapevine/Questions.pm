package Grapevine::Questions;
use Mojo::Base 'Mojolicious::Controller';

sub enter_new {
    my $self = shift;
    $self->stash(title => 'Enter a New Question');
    $self->render('questions/new');
}

sub submit_new {
    my $self = shift;

    my $new_question = $self->db->resultset('Question')->create( {
        title       => $self->param('title'),
        description => $self->param('description'),
    } );

    # show the newly submitted question
    my $question_id = $new_question->id;
    $self->redirect_to("/questions/$question_id");
}

sub show {
    my $self = shift;

    my $question_id = $self->param('question_id');
    my $question = $self->db->resultset('Question')->find($question_id);

    $self->render_not_found if ! defined $question;

    $self->stash(
        question => $question,
        title => $question->title,
    );
    $self->render('questions/show')
}

sub list {
    my $self = shift;

    $self->stash(title => 'Latest Questions');

    my @questions = $self->db->resultset('Question')->search(
        undef, { order_by => { -desc => 'created'} }
    );
    $self->stash(questions => \@questions);

    $self->render('questions/list');
}

1;
