#!/usr/bin/perl
use strict;

die "perl sample_relocate.pl <sample.list> <final samples directory> <candidate samples fastq.gz previous directories ...> \n" if @ARGV <=2;
my(%sampleID_hash);
open my $list,shift @ARGV;
while(<$list>){
	chomp;
	$sampleID_hash{$_} ++ ;
}
close $list;
my $term_dir = shift @ARGV;
for(@ARGV){
	opendir my $dh,$_;
	$_ .= '/' unless ($_=~ /\/$/);
	my @files = readdir $dh;
	for my $file(@files){
		if($file =~ /(\w+)\_S(.*)\.fastq.gz$/){
			if(exists $sampleID_hash{$1}){
				`ln -s $_$file $term_dir`;
				#print "ln -s $_$file $term_dir\n";
			}
			else{
				next;
			}
		}
	}
	closedir $dh;
}
