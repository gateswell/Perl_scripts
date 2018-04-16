#!/usr/bin/perl
use strict;
die "perl $0 <list> <candidate directory>\n" if @ARGV != 2;
open my $list,$ARGV[0];
my(%sample_hash,%pos_hash,%num);
while(<$list>){
	chomp;
	my @tmp = split /\t/,$_;
	my $sampleID = $tmp[0];
	my $pos = join ('|',$tmp[1],$tmp[2]);
	$sample_hash{$sampleID} =1;
	$pos_hash{$sampleID}{$pos}=1;
}
close $list;

my @harm_list = qw /SIFT_score Polyphen2_HVAR_score MutationTaster_score MutationAssessor_score FATHMM_score PROVEAN_score MetaSVM_pred MetaLR_pred LRT_pred/;
opendir my $dh,$ARGV[1];
$ARGV[1] .= '/' unless $ARGV[1]=~ /\/$/;
for(readdir $dh){
	$_=~ /^(\w+)\_S(\d+)\.hg19_multianno.txt$/;
	my $sample_id = $1;
	if(exists $sample_hash{$sample_id}){
		open my $fh,$ARGV[1].$_;
		my $head = <$fh>;
		chomp($head);
		my $i =0;
		for(split /\t/,$head){
			$num{$_} =$i;
			$i ++;
		}
		open OUT,'>',"$sample_id\_9database_result.txt";
		my $new_head = join("\t",@harm_list);
		print OUT "Chr\tStart\tEnd\tRef\tAlt\tGene.refGene\t",$new_head,"\n";
		while(<$fh>){
			chomp;
			my @tmp = split /\t/,$_;
			my $pos = join ('|',$tmp[0],$tmp[1]);
			if(exists $pos_hash{$sample_id}{$pos}){
				print OUT $tmp[$num{Chr}],"\t$tmp[$num{Start}]\t$tmp[$num{End}]\t$tmp[$num{Ref}]\t$tmp[$num{Alt}]\t$tmp[$num{'Gene.refGene'}]\t";
				foreach my $a(@harm_list){
					print OUT $tmp[$num{$a}],"\t";
				}
				print OUT "\n";
			}
		}
		close $fh;
	}
	else{next;}
}
closedir $dh;
