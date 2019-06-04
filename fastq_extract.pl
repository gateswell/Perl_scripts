#!/usr/bin/perl
# use for trim extract length of fastq and select extract number reads for further analysis.
use strict;
use File::Basename;
use Cwd qw(abs_path getcwd);
use Getopt::Long;

my $usage=<<'USAGE';

Usage:
	perl fastq_extract.pl [options]
	-s --size INT 	the length of reads
	-n --num INT  	num of reads wanted
	-p --pct fllat	percentage of reads extract (only one of pct or num can be setted, Not allow both)
	-l --list FILE 	the list of all fastq file
	-o --outdir STRING output directory 
	-h --help	show help infomation
Example:
	perl fastq_extract.pl -s 50 -n 10000000 -l fq.list
	perl fastq_extract.pl -s 50 -n 10000000 -l fq.list -o path/outdir
	perl fastq_extract.pl -p 0.1 -l fq.list -o path/outdir

=======================list format=============================
format1:
/path/01.Raw_data/fq1_1.fq.gz	/path/01.Raw_data/fq1_2.fq.gz
/path/01.Raw_data/fq2_1.fq.gz	/path/01.Raw_data/fq2_2.fq.gz

format2:
/path/01.Raw_data/fq1_1.fq.gz
/path/01.Raw_data/fq2_1.fq.gz
===============================================================
USAGE

my($size,$num,$pct,$list,$outdir,$help);
GetOptions(
	'size|s:i'=>\$size,
	'num|n:i'=>\$num,
	'pct|p:f'=>\$pct,
	'list|l=s'=>\$list,
	'outdir|o:s'=>\$outdir,
	'help|h'=>\$help
);
die $usage if((!$num || !$pct) && !$list || $help);

my $path = abs_path(getcwd());
$path .= '/' if $path !~ /\/$/;

$outdir ||= './';

open LIST,"<$list" || die $!;
my (%type,%sample);
while(<LIST>){
	chomp;
	my @tmp=split /\s+/,$_;
	if(@tmp==1){
		if(-e $tmp[0]){
		#	my $direcname = dirname $tmp[0];
			my $filename = basename $tmp[0];
			my $prefix= $1 if $filename=~/(\w+).fq(.gz)?/;
			$type{$prefix} = 'SE';
			$sample{$prefix}[0] = $tmp[0];
		}else{die "$tmp[0]: No such file!\n";}
	}
	elsif(@tmp==2){
		if(-e $tmp[0] or -e $tmp[1]){
		#	my $direcname = dirname $tmp[0];
			my $filename = basename $tmp[0];
			my $prefix= $1 if $filename=~/(\w+)_1.fq(.gz)?/;
			$type{$prefix} = 'PE';
			$sample{$prefix}[0] = $tmp[0];
			$sample{$prefix}[1] = $tmp[1];
		}else{die "$tmp[0] or $tmp[1]: No Such file!\n";}
	}
	else{
		die "the format of list is incorrect! check it again\n";
	}
	
}
my $format_size;
if($num){
	$format_size=($num/1000 <1)? ($num/1000).'K':($num/1000000 < 1)? ($num/1000).'K': ($num/1000000000 < 1)? ($num/1000000).'M' : ($num/1000000000).'G'; 
}
#elsif($pct){
#	$format_size=$pct;
#}
for my $file(sort {$a<=>$b} keys %sample){
	my ($fh1,$fh2);
	if($sample{$file}[0] =~ /.fq$/){
		open $fh1,$sample{$file}[0] || die "can't open $sample{$file}[0]:$!\n";
		open $fh2,$sample{$file}[1] || die "can't open $sample{$file}[1]:$!\n" if $type{$file} eq 'PE';
	}
	elsif($sample{$file}[0] =~ /.fq.gz$/){
		open $fh1," gzip -dc $sample{$file}[0] |" || die "can't open $sample{$file}[0]:$!\n";
		open $fh2," gzip -dc $sample{$file}[1] |" || die "can't open $sample{$file}[1]:$!\n" if $type{$file} eq 'PE';
	}
	my $direcname = dirname $sample{$file}[0];
	my $filename = basename $sample{$file}[0];
	my $filename2= basename $sample{$file}[1] if $type{$file} eq 'PE';
	my $fqstatname = $filename;
	$fqstatname =~ s/gz/fqStat.txt/g if $sample{$file}[0] =~ /.fq.gz$/;
	#$filename =~ s/\.fq(.gz)?/\_$format_size.fq$1/;
	open my $fqstat, $direcname.'/'.$fqstatname || die "no such file: $direcname/$fqstatname: $!\n";
	my ($readnum,$readlen);
	while(<$fqstat>){
		$readnum = (split /\t/,$_)[1] if $_=~/^#ReadNum/;
		$readlen = (split /\t/,$_)[1] if $_=~/^#row_readLen/;
	}
	close $fqstat;
	if(! $size){
		$size=$readlen;
	}
	if($pct){
		my $readsNum = $pct*$readnum;
		$format_size = ($readsNum/1000 <1)? ($readsNum/1000).'K':($readsNum/1000000 < 1)? ($readsNum/1000).'K': ($readsNum/1000000000 < 1)? ($readsNum/1000000).'M' : ($readsNum/1000000000).'G';
	}
	$filename =~ s/\.fq(.gz)?/\_$format_size.fq$1/;
	$filename2 =~ s/\.fq(.gz)?/\_$format_size.fq$1/ if $type{$file} eq 'PE';
	my $ratio;
	if($num){
		$ratio = $num/$readnum;
	}
	elsif($pct){
		$ratio = $pct;
	}
	else{
		print STDERR "parameter $pct or $num undefined!\n";
	}
	#my $i =0;
	open OUT,"| gzip -9 > $path\/$filename" || die $!;
	open OUT2,"| gzip -9 > $path\/$filename2" || die $! if $type{$file} eq 'PE';
	while(<$fh1>){
		chomp(my $fq1 = $_);
		chomp(my $fq2 = <$fh1>);
		chomp(my $fq3 = <$fh1>);
		chomp(my $fq4 = <$fh1>);
		#$size=$size?$size:length($fq2)+1;
		chomp(my $Fq1 = <$fh2>) if $type{$file} eq 'PE';
		chomp(my $Fq2 = <$fh2>) if $type{$file} eq 'PE';
		chomp(my $Fq3 = <$fh2>) if $type{$file} eq 'PE';
		chomp(my $Fq4 = <$fh2>) if $type{$file} eq 'PE';
		my $rdn = rand(1);
		my($tfq2,$tfq4,$tFq2,$tFq4);
		if($type{$file} eq 'SE'){
			if($size < $readlen){
				$tfq2 = substr($fq2,0,$size);
				$tfq4 = substr($fq4,0,$size);
			}else{
				$tfq2 = $fq2;
				$tfq4 = $fq4;
			}
		}elsif($type{$file} eq 'PE'){
			if($size < $readlen){
				$tfq2 = substr($fq2,0,$size);
				$tfq4 = substr($fq4,0,$size);
				$tFq2 = substr($Fq2,0,$size);
				$tFq4 = substr($Fq4,0,$size);
			}else{
				$tfq2 = $fq2;
				$tfq4 = $fq4;
				$tFq2 = $Fq2;
				$tFq4 = $Fq4;
			}
		}
		if($rdn <= $ratio){
			print OUT "$fq1\n$tfq2\n$fq3\n$tfq4\n";
			print OUT2 "$Fq1\n$tFq2\n$Fq3\n$tFq4\n";
			#$i ++;
		}else{next;}
	}
	close OUT;
	close OUT2 if $type{$file} eq 'PE';
	close $fh1;
	close $fh2 if $type{$file} eq 'PE';
}
