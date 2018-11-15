#!/usr/bin/perl
use strict;
use File::Basename;
open my $fh1,$ARGV[0];
open my $fh2,$ARGV[1];
my ($name1,$name2)=(basename($ARGV[0]),basename($ARGV[1]));
$name1=~s/.vcf//;$name2=~s/.vcf//;
my (%hash,%num,%total);
while(<$fh1>){
	next if /^#/;
	next unless /PASS/;
	$total{vcf1} ++;
	my @tmp = split /\t/,$_;
	my $key = join('|',(split /\t/,$_)[0..4]);
	if(length($tmp[3]) == length($tmp[4]) && length($tmp[4])==1){
		$hash{$key}{snp} +=1;
	}
	else{
		$hash{$key}{indel} += 1;
	}
}
close $fh1;
while(<$fh2>){
	next if /^#/;
	next unless /PASS/;
	$total{vcf2} ++;
	my @tmp = split /\t/,$_;
	my $key = join('|',(split /\t/,$_)[0..4]);
	if(length($tmp[3]) == length($tmp[4]) && length($tmp[4])==1){
		$hash{$key}{snp} +=2;
	}
	else{
		$hash{$key}{indel} += 2;
	}
}
close $fh2;

for my $key(keys %hash){
	for my $type(keys %{$hash{$key}}){
		if($hash{$key}{$type} == 1){
			$num{$type}{vcf1} +=1;
		}
		elsif($hash{$key}{$type} == 2){
			$num{$type}{vcf2} +=1;
		}
		elsif($hash{$key}{$type} == 3){
			$num{$type}{both} +=1;
		}
	}
}
print "\tSNP\tInDel\n";
#print "$name1\_spec:\t$num{snp}{vcf1}\($num{snp}{vcf1}/$total{vcf1}*100%\)\t$num{indel}{vcf1}\($num{indel}{vcf1}/$total{vcf1}*100%\)\n$name2\_spec:\t$num{snp}{vcf2}\($num{snp}{vcf2}/$total{vcf2}*100%\)\t$num{indel}{vcf2}\($num{indel}{vcf2}/$total{vcf2}*100%\)\nboth:\t$num{snp}{both}\t$num{indel}{both}\n";
my $per1 = sprintf("%.2f%%",$num{snp}{vcf1}/$total{vcf1}*100);
my $per2 = sprintf("%.2f%%",$num{indel}{vcf1}/$total{vcf1}*100);
my $per3 = sprintf("%.2f%%",$num{snp}{vcf2}/$total{vcf1}*100);
my $per4 = sprintf("%.2f%%",$num{indel}{vcf2}/$total{vcf1}*100);
print "$name1\_spec:\t$num{snp}{vcf1}\($per1\)\t$num{indel}{vcf1}\($per2\)\n$name2\_spec:\t$num{snp}{vcf2}\($per3\)\t$num{indel}{vcf2}\($per4\)\nboth:\t$num{snp}{both}\t$num{indel}{both}\n";
