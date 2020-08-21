#!/usr/bin/perl
use strict;
use Getopt::Long;
use Cwd qw(abs_path);
use File::Basename;
my($fq1,$fq2,$size,$outdir,$prefix,$help);
GetOptions(
	"read1|f=s" => \$fq1,
	"read2|r=s" => \$fq2,
	"size|s=s"  => \$size,
	"outdir|o:s"=> \$outdir,
	"prefix|p:s"=> \$prefix,
	"help|h:s"  => \$help
);

if(!defined($fq1) || !defined($fq2) || !defined($size) || defined($help)){
	print STDERR <<USAGE;
Usage:
	perl $0 [optiones]
			-read1,	-f 	read 1 fq.gz
			-read2,	-r	read 2 fq.gz
			-size,	-s	extract reads number(options: M|G|m|g)
			-outdir,-o	output directory [default ./]
			-prefix,-p	the prefix of output file [default: output]
			-help,	-h	print the help information and exit
Example:
	perl $0 -f sample_1.fq.gz -r sample_2.fq.gz -size 4G -outdir /mnt/g/extract/sample -p sampleExtract
System:
	Linux
USAGE
	exit;
}

#=======configure info=======
$outdir ||= "./";
$prefix ||= "output";

#=======main script=====
my($readnum,$pct);
my $extract_size= ($size =~ /G/i ) ? $size*1000000000 : (($size=~/M/i)? $size*1000000:$size);
print $extract_size;

if($fq1=~/gz$/){
	die "the fastq file: $fq1 unexists\n" unless -e $fq1;
	&checkfq($outdir,$fq1,$prefix);
	my $readnum=`gzip -dc $fq1|wc -l`;
	chomp($readnum);$readnum=~s/\r//;
	if($readnum*2 < $extract_size){	#以防数据量超过原数据量
		die "the size input is larger than original data, please set a smaller number\n";
	}elsif($readnum*2 == $extract_size){
		die "oops, the size input is same as the original date, no need to extract\n";
	}else{
		$pct=$extract_size/($readnum*2);
	}
	&extractfq($fq1,$fq2,$pct,$outdir,$prefix);
}else{
	die "the fastq file: $fq1 unexists\n" unless -e $fq1;
	&checkfq($outdir,$fq1,$prefix);
	my $readnum=`wc -l $fq1`;
	chomp($readnum);$readnum=~s/\r//;
	if($readnum*2 < $extract_size){	#以防数据量超过原数据量
		die "the size input is larger than original data, please set a smaller number\n";
	}elsif($readnum*2 == $extract_size){
		die "oops, the size input is same as the original date, no need to extract\n";
	}else{
		$pct=$extract_size/($readnum*2);
	}
	&extractfq($fq1,$fq2,$pct,$outdir,$prefix);
}

#======subroutine=======
sub checkfq{
	my($outdir,$fq1,$prefix)=@_;
	$outdir=abs_path($outdir);
	my $fq1full=abs_path($fq1);
	my $orifq1=basename($fq1);$orifq1=~s/.fq*//;
	my $outfq1full="$outdir/$prefix.1";
	my $orifq1full="$fq1full/$orifq1";
	if($outfq1full eq $orifq1full){
		die "you will cover the original fq file, please set another prefix name and output path\n";
	}
}

sub extractfq{
	my($fq1,$fq2,$pct,$outdir,$prefix)=@_;
	open my $f1,"gzip -dc $fq1|" || die "$fq1 unexist \n";
	open my $f2,"gzip -dc $fq2|" || die "$fq2 unexist \n";
	open my $o1,"| gzip -9 > $outdir/$prefix.1.fq.gz" || die $!;
	open my $o2,"| gzip -9 > $outdir/$prefix.2.fq.gz" || die $!;
	while(<$f1>){
		my $h1=$_;
		my $h2=<$f2>;
		my $s1=<$f1>;
		my $p1=<$f1>;
		my $q1=<$f1>;
		my $s2=<$f2>;
		my $p2=<$f2>;
		my $q2=<$f2>;
		my $rdn = rand(1);
		if($rdn<=$pct){
			print $o1 "$h1$s1$p1$q1";
			print $o2 "$h2$s2$p2$q2";
		}else{
			next;
		}
	}
}