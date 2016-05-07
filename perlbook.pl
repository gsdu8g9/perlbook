#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::DOM;
use utf8;
use open ':encoding(utf8)';
use HTML::Entities;
use FindBin;

get '/' => sub {
    my $self = shift;
    
    $self->render('index');
}; 

get '/signin' => sub {
    my $self = shift;

    my $pass = $self->param('pass');

    return $self->reply->not_found() 
        unless $pass && $pass eq "123456";

    $self->cookie(logged => 1, {path => '/', expires => time + 24*60*60});
    $self->redirect_to('/');
};

post '/save' => sub {
    my $self = shift;
    my $id = $self->param('id');
    my $html = $self->param('html');
    my $page = $self->param('page');
    
    $self->respond_to(
        json => sub { $self->render( json => { error => "params missed" } ) } 
    ) unless $id && $html && $page;
    
    my $filename = "$FindBin::Bin/templates${page}.ep";
    
    my $outfile = "${filename}_";
    open OUT, ">$outfile";
    open IN, "<$filename";
    if ($!){
        $self->respond_to(
            json => sub { $self->render( json => { error => 'file not found' } ) } 
        );
    }
    my $dom;
    {
        
        local $/;
        my $file = <IN>;
        $dom = Mojo::DOM->new($file);
        close IN;
    }
    
    unless ($dom){
        close OUT;
        $self->respond_to(
            json => sub { $self->render( json => { error => 'dom not created' } ) } 
        );
    }
    
    $dom->at("p[content_id=$id]")->content($html);
    my $res = $dom->content;
    $res =~ s/&#39;/\'/g;
    print OUT $res;
    close OUT;
    
    rename $outfile, $filename;
    
    $self->respond_to(
        json => sub { $self->render( json => { ok => 1 } ) } 
    );
};

get '/:page' => sub {
  my $self = shift;
  my $page = $self->stash('page');
  $page =~ s/\.html$//;
  
  if ($self->cookie('logged') == 1){
    
    my $html = $self->render_to_string($page);
    my $i = 0;
    $html =~ s/(<p)\s(content_id=)/$1 contenteditable=\"true\" $2/ig;
    return $self->render(text => $html);
  }
   
  $self->render( $page ) or $self->reply->not_found();
};

app->config(hypnotoad => {listen => ['http://*:3000'], workers => 1 }) ;
app->start;

__END__

perl -e 'print "\n\n";opendir(my $dh, $ARGV[0]) or die "ERROR::$!";while(my $file = readdir($dh)){ next unless $file =~ /^\d\d/; my $in = "templates/$file"; my $out = $in . "_"; open OUT, ">$out"; open IN, "<$in"; while(<IN>){s/(<p)([\s>])/$1 . " content_id=\"" . $i++ . "\"" . $2/eg; print OUT $_;} rename $out, $in; print "$in ok\n"; }' templates
