#!/usr/bin/perl -w
use strict;
use warnings;

use Mojo::UserAgent;

my $ua = new Mojo::UserAgent;

my $site = "http://modernperlbooks.com/books/modern_perl_2014/";
my $tx = $ua->get($site);

die "Error1::$!\n" unless $tx->success;
=head2
my $wrapper = $tx->res->dom->html;

open FILE, ">content/wrapper.html" or die "ERROR::$!\n\n";
print FILE $wrapper;
close FILE; 

=cut
my @a = $tx->res->dom->html->body->find('ul')
			->grep( sub { $_->attr('class') eq "nav nav-list.html" } )
			->find('li > a')->attr('href')->each;
			
my @url = split /\s/, $a[0];

push @url, "index.html";
for my $url (@url){
	my $link = $site . $url;
	print "$site =>$url", "\n";
	 
	my $tx = $ua->get($link);
	die "Error::$!\n" unless $tx->success;
	my $content = $tx->res->dom->html->body->find('div')->grep( sub { $_->attr('class') eq "span8" } );
	open FILE, ">templates/$url.ep" or die "Error::$!\n";
	print FILE "\% layout 'wrapper';\n";
	print FILE $content;
	close FILE;

}
