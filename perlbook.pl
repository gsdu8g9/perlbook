#!/usr/bin/env perl
use Mojolicious::Lite;

get '/' => sub {
	my $self = shift;
	
	$self->render('index');
}; 

get '/:page' => sub {
  my $self = shift;
  my $page = $self->stash('page');
  $page =~ s/\.html$//;
  $self->render( $page ) or $self->render_not_found();
};


app->config(hypnotoad => {listen => ['http://*:3000'], workers => 1 }) ;
app->start;


