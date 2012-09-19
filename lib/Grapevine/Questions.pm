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

    my $new_answer = $self->session('answer') || '';
    delete $self->session->{answer};

    $self->render(
        'questions/show',
        question => $question,
        answers  => [$question->answers],
        new_answer => $new_answer,
    );
}

sub submit_answer {
    my $self = shift;

    my $question_id = $self->param('question_id');

    if ( ! $self->session('user') ) {
        $self->flash(message => 'You must log in to submit an answer');
        $self->session(
            url => $self->url_for('question', question_id => $question_id),
            answer => $self->param('answer'),
        );
        return $self->redirect_to('login');
    }
    my $user_id = $self->session('user');

    my $question = $self->db->resultset('Question')->find($question_id);
    $question->add_to_answers( {
        user_id => $user_id,
        content => $self->param('answer'),
    } );
    $self->redirect_to('question', question_id => $question_id);
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
