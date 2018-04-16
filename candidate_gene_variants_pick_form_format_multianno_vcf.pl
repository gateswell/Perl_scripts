#!/usr/bin/perl
use strict;
die"perl candidate_gene_variants_pick.pl <gene.list> <formated multianno.vcf> <output formated multianno.vcf>\n" if @ARGV !=3;
open my $list,$ARGV[0];
my (%hash,%num);
while(<$list>){
	chomp;
	$hash{$_}=1;	
}
close $list;

open my $mul,$ARGV[1];	#formated_multianno.txt
open OUT,'>',$ARGV[2];
my $head = <$mul>;
print OUT $head;
my $i =0;
for(split /\t/,$head){
	$i ++;
	$num{$_}=$i-1;
}
while(<$mul>){
	chomp;
	my @tmp = split /\t/,$_;
	if(exists $hash{$tmp[$num{Gene}]}){
		print OUT $_,"\n";
	}
	else{next;}
}
close $mul;
