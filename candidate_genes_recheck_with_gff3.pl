#!/usr/bin/perl
# this scrip is used for rotating gene name to gff3 gene name or its gene_synomym gene name
use strict;
die "perl $0 <untrans gene.list>\n" if @ARGV !=1;
my $gff = "ref_GRCh37.p13_top_level.gff3";
open my $gff_fh,$gff;
my(%relate_hash,%alias_hash,%gene_hash,%aliss_gene_hash);
while(<$gff_fh>){
	next if /^#/;
	my @tmp = split /\t/,$_;
	next if $tmp[1] !~ /BestRefSeq/;
	next unless $tmp[2] =~ /gene/;
	for(split /;/,$tmp[8]){
		my($a,$b) = split /\=/,$_;
		$relate_hash{$a} =$b;
	}
	$gene_hash{$relate_hash{gene}}=1;
	if(exists $relate_hash{gene_synonym}){
		my @alias = split /,/,$relate_hash{gene_synonym};
		for(@alias){
			$aliss_gene_hash{$_}=1;
			$alias_hash{$_} = $relate_hash{gene};
		}
	}
}
close $gff_fh;

open my $fh,$ARGV[0];
my $name;
if($ARGV[0]=~ /(.*).(list|txt)$/){
	$name = $1;
}
elsif($ARGV[0]=~ /\/(.*)\.(\w+)$/){
	$name =$1;
}
open OUT,'>',"$name\_trans.txt";
while(<$fh>){
	chomp;
	my @tmp = split /\t/,$_;
	if(@tmp ==1){
		if(exists $gene_hash{$tmp[0]}){
			print OUT $tmp[0],"\n";
		}
		elsif(exists $aliss_gene_hash{$tmp[0]}){
			print OUT $alias_hash{$tmp[0]},"\n";
		}
		else{
			print $tmp[0],"\tuncovered\n";
			next;
		}
	}
	else{	#more than one genes in one line
		for my $candi(@tmp){
			if(exists $gene_hash{$tmp[0]}){
				print OUT $candi,"\n";
				last;
			}
			elsif(exists $aliss_gene_hash{$candi}){
				print OUT $alias_hash{$candi},"\n";
				last;
			}
			else{
				print $candi,"\tuncovered\t";
				#next;
				last;
			}
		}
	}
}
close $fh;
