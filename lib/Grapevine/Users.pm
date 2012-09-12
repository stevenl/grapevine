package Grapevine::Users;
use Mojo::Base 'Mojolicious::Controller';

sub enter_new {
    my $self = shift;

    $self->stash(message => '') if ! defined $self->stash('message');
    $self->render('users/new');
}

sub submit_new {
    my $self = shift;

    my $new_user = $self->db->resultset('User')->new( {
        username => $self->param('username'),
        password => $self->param('password'),
        email    => $self->param('email'),
    } );
    $new_user->insert;

    $self->session(username => $new_user->username);
    $self->redirect_to('/');
}

sub login {
    my $self = shift;

    $self->stash(error => '');
    $self->stash(username => '') if ! defined $self->stash('username');
    $self->render('users/login');
}

sub submit_login {
    my $self = shift;

    my $user = $self->db->resultset('User')->find(
        { username => $self->param('username') }
    );

    if ( ! defined $user || ! $user->authenticate($self->param('password')) ) {
        $self->stash( message => 'username or password is invalid' );
        $self->stash( username => $self->param('username') );
        return $self->render('users/login');
    }

    $self->session(username => $user->username);
    $self->redirect_to('/');
}

sub logout {
    my $self = shift;
    $self->session(expires => 1);
    $self->redirect_to('/');
}

1;
