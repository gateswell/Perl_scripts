#!/usr/bin/perl
#this script is used for calculate every sample's data size and theory depth
#Author: Cao Shuhuan
#Date: Wed Apr 11 16:13:18 CST 2018
#Contact with caoshuhuan@catb.org.cn if any problem happens
#example: perl multiqc_fasqc_data_calculate_2xlsx.pl multiqc_fastqc.txt
 
use strict;
use Encode;
use utf8;
use Excel::Writer::XLSX;
die "perl multiqc_fasqc_data_calculate.pl <multiqc_fastqc.txt>\n" if @ARGV !=1;
open my $fh,$ARGV[0];
my $output = "multiqc_DataSize_and_Depth.xlsx";
my $workbook  = Excel::Writer::XLSX -> new($output);
my $worksheet = $workbook->add_worksheet();
my $j =1;
my $head = <$fh>;
my(%index,%data,$i);
for(split /\t/,$head){
	$i++;
	$index{$_} = $i;
}
my $format1 = $workbook -> add_format();
$format1 -> set_bold(1);
$format1 -> set_font('Times New Roman');
my $format2 = $workbook -> add_format();
$format2 -> set_align( 'left' );
$format2 -> set_font('Times New Roman');

$worksheet -> freeze_panes(1,0);
$worksheet -> set_column('A:A',12.5);
$worksheet -> set_column('B:B',12);
$worksheet -> set_column('C:C',15);
$worksheet -> write(0,0,"sampleID",$format1);
$worksheet -> write(0,1,"Data_size",$format1);
$worksheet -> write(0,2,"theory_depth",$format1);
while(<$fh>){
	my @tmp = split /\t/,$_;
	if($tmp[0] =~ /(\w+)\_S(\d+|(\d+\_L\d+))\_R1/){
		my $name = $1;
		$data{$name} = $tmp[$index{'Total Sequences'} - 1];
		$worksheet -> write($j,0,$name,$format2);
		$worksheet -> write($j,1,3*$data{$name}*(10**-7),$format2);
		$worksheet -> write($j,2,0.6*$data{$name}*(10**-5),$format2);
	}else{
		next;
	}
	$j ++;
} #basic_statistics
close $fh;
