package Grapevine::Users;
use Mojo::Base 'Mojolicious::Controller';

sub enter_new {
    my $self = shift;
    $self->render('users/signup');
}

sub submit_new {
    my $self = shift;

    my $new_user = $self->db->resultset('User')->create( {
        username => $self->param('username'),
        password => $self->param('password'),
        email    => $self->param('email'),
    } );

    $self->session(
        user     => $new_user->id,
        username => $new_user->username,
    );
    $self->redirect_to('home');
}

sub login {
    my $self = shift;
    $self->stash(username => '') if ! defined $self->stash('username');
    $self->render('users/login');
}

sub submit_login {
    my $self = shift;

    my $user = $self->db->resultset('User')->find(
        { username => $self->param('username') }
    );

    if ( ! defined $user || ! $user->authenticate($self->param('password')) ) {
        $self->flash(
            message  => 'username or password is invalid',
            username => $self->param('username'),
        );
        return $self->redirect_to('login');
    }

    $self->session(
        user     => $user->id,
        username => $user->username
    );
    return $self->redirect_to( $self->session('url') ) if $self->session('url');

    $self->redirect_to('home');
}

sub logout {
    my $self = shift;
    $self->session(expires => 1);
    $self->redirect_to('home');
}

1;
