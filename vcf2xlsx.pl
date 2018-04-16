#!/usr/bin/perl
use strict;
use Encode;
use utf8;
use Excel::Writer::XLSX;

die "perl vcf2xlsx.pl <vcf>\n" if @ARGV !=1;
my $name;
if($ARGV[0]=~/(.*)\/(\w+)\.vcf/){
	$name = $2;
}
elsif($ARGV[0]=~/(\w+)\.vcf/){
	$name = $1;
}
my $output = "$name.xlsx";
my $workbook  = Excel::Writer::XLSX -> new($output);

my $worksheet1 = $workbook->add_worksheet('sheet1');

open my $fh,$ARGV[0];
my $j =0;
while(<$fh>){
	chomp;
	my @tmp = split /\t/,$_;
	for my $i(0..$#tmp){
		$tmp[$i] = decode("utf8",$tmp[$i]);
		$worksheet1 -> write($j,$i,$tmp[$i]);
	}
	$j ++;
}
close $fh;
