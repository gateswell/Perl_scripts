#!/usr/bin/perl
#Usage: used for generating summary file of 8_Interface directory  
#Author: Cao Shuhuan
#version: v1.0
#Date: Wed Jan 10 18:04:05 CST 2018

use strict;
use Getopt::Std;

my %opts;
getopts("I:o:h",\%opts);

my $interdir = $opts{I};
my $output   = $opts{o};
$interdir .= '/' unless $interdir=~/\/$/;
if(defined $output){
	open OUT,'>',$output;
}
else{
	open OUT,'>',$interdir."Interface_summary.txt";
}
&print_usage unless (defined($interdir));
#&print_usage unless (defined($output));
&print_usage if (defined($opts{h}));

opendir my $dh,$interdir;
my @interfiles = readdir($dh);
my @variants = grep /variant_types_number/,@interfiles;
my @mdepths  = grep /MeanDepth_Coverage/,@interfiles;
my @t4s      = grep /T4.txt$/,@interfiles;
my @t6s      = grep /T6.txt$/,@interfiles;
closedir $dh;
my(%total_num,%meanDp,%twentyDp,%tenDp,%fiftyDp,%hundredDp,%t4Num,%t6Num);

for my $variant(@variants){
	$variant=~/(\w+)\_(\w+)\_variant_types_number.txt/;
	my $name = $1;
	open my $fh,$interdir.$variant || die "can't open $variant\n";
	while(<$fh>){
		next if /^#/;
		chomp;
		my @tmp = split /\t/,$_;
		$total_num{$name} = $tmp[1] if $tmp[0]=~/total/;
	}
	close $fh;
}

for my $mdepth(@mdepths){
	$mdepth=~ /(\w+)_(\w+)_MeanDepth_Coverage.txt/;
	my $name = $1;
	open my $fh,$interdir.$mdepth || die "can't open $mdepth\n";
	my %idx;
	my $head = <$fh>;
	$head =~ s/ //g;
	my @str = split /\t/,$head;
	for(0..$#str){
		$idx{$str[$_]}=$_;
	}
	while(<$fh>){
		$_=~ s/ //g;
		chomp;
		my @tmp = split /\t/,$_;
		$meanDp{$name} = $tmp[$idx{Mean_depth}];
		$twentyDp{$name}=$tmp[$idx{'>20x'}];
		$tenDp{$name}=$tmp[$idx{'>10x'}];
		$fiftyDp{$name}=$tmp[$idx{'>50x'}];
		$hundredDp{$name}=$tmp[$idx{'>50x'}+1];
		#print $name,"\t",$meanDp{$name},"\t",$twentyDp{$name},"\n";
	}
	close $fh;
}

for my $t4 (@t4s){
	$t4 =~ /(\w+)\_(\w+)\_T4.txt/;
	my $name =$1;
	my $line=`wc -l $interdir$t4`;
	my @tmp = split / /,$line;
	$t4Num{$name} = $tmp[0];
	#print $name,"\t",$t4Num{$name},"\n";	
}

for my $t6 (@t6s){
	$t6 =~ /(\w+)\_(\w+)\_T6.txt/;
	my $name =$1;
	my $line=`wc -l $interdir$t6`;
	my @tmp = split / /,$line;
	$t6Num{$name} = $tmp[0];
}

print OUT "\#SampleID\tvariants_sum\tHotgene_Guidline\tPotential\tMean_depth\t20X_coverage\t10X_coverage\t50X_coverage\t100X_coverage\n";
foreach (sort keys %total_num){
	print OUT $_,"\t",$total_num{$_},"\t",$t4Num{$_},"\t",$t6Num{$_},"\t",$meanDp{$_},"\t",$twentyDp{$_},"\t",$tenDp{$_},"\t",$fiftyDp{$_},"\t",$hundredDp{$_},"\n";
}

sub print_usage{
	die "Usage\:\nperl Interface_summary4all_samples.pl
	-I path/to/8_Interface/
	-o summary.txt
	-h help\n";
}
