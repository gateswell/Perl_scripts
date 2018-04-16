#!/usr/bin/perl
use strict;
die "perl batch_ln.pl <origin directory> <sampleID list> <output dir> <file type>\n" if @ARGV !=4;
opendir my $dh1,$ARGV[0];	#origin directory
my @files = readdir($dh1);
$ARGV[0] .= '/' unless($ARGV[0]=~/\/$/);
open my $list,$ARGV[1];		#sampleID list 
my $outptdir = $ARGV[2];
my $type  = $ARGV[3];
my %hash;
while(<$list>){
	chomp;
	my $sample = $_;
	$hash{$sample} =1;
}
close $list;

for my $file(@files){
	if($file =~ /(\w+)\_(.*)(\.|\_)$type$/){
		if(exists $hash{$1}){
			`ln -s $ARGV[0]$file $outptdir`;
		}
	}
	#elsif($file =~ /(\w+)\_(.*)\.bam$/){
	#	if(exists $hash{$1}){
	#		print "ln -s $ARGV[0]$file $outptdir\n";
	#	}
	#}
}
closedir $dh1;
