#!/usr/bin/perl
use strict;
use Cwd;
#perl /catb/software/scripts/WES/diff_lane_fastq_merge.pl <raw_data directory>
opendir my $raw_dir,$ARGV[0];
$ARGV[0] .='/' unless $ARGV[0]=~/\/$/;
my @files = readdir($raw_dir);
#print "@files";
my $dir = getcwd();
my (%same_R1,%same_R2,%num,%sample_R1,%sample_R2,%out_R1,%out_R2,@all);
for(@files){
	next if $_=~/^Undetermined/;
	if($_ =~ /(.*)\_L00(\d+)\_R1_(\d+)\.fastq.gz$/){
		push @{$same_R1{$1}},$ARGV[0].$_;
		$num{$1}++;
		$sample_R1{$1} = $_;
		$out_R1{$1} = "$1\_R1\_$3.fastq.gz";
		#print "$_\n";
	}
	if($_ =~ /(.*)\_L00(\d+)\_R2_(\d+)\.fastq.gz$/){
		$num{$1}++;
		$sample_R2{$1} = $_;
		$out_R2{$1} = "$1\_R2\_$3.fastq.gz";
		push @{$same_R2{$1}},$ARGV[0].$_;
		#print "$_\n";
	}
}
foreach (sort keys %same_R1){
	#open my $R1,'>',"$_\_cat.sh";
	#my $sh = "$_\_cat.sh";
	if(@{$same_R1{$_}} == 2){
		open my $R1,'>',"$_\_R1_cat.sh";
		my $sh = "$_\_R1_cat.sh";
		@{$same_R1{$_}} = sort @{$same_R1{$_}};
		print $R1 "cat @{$same_R1{$_}} \> $_\_R1_001.fastq.gz\n";
		push @all,$sh;
	}
	else{next;}
	#push @all,$sh;
}
foreach (sort keys %same_R2){
	#open my $R2,'>',"$_\_cat.sh";
	#my $sh = "$_\_cat.sh";
	if(@{$same_R2{$_}} == 2){
		open my $R2,'>',"$_\_R2_cat.sh";
		my $sh2 = "$_\_R2_cat.sh";
		@{$same_R2{$_}} = sort @{$same_R2{$_}};
		print $R2 "cat @{$same_R2{$_}} \> $_\_R2_001.fastq.gz\n";
		push @all,$sh2;
	}
	else{next;}
	#push @all,$sh;
	#print "@{$same_R1{$_}}\t";
}
closedir $raw_dir;
for(keys %num){
	if ($num{$_} ==2){
		open my $cp,'>',"$_\_cp.sh";
		my $cp_sh = "$_\_cp.sh";
		print $cp "cp $ARGV[0]$sample_R1{$_} $out_R1{$_}\n";
		print $cp "cp $ARGV[0]$sample_R2{$_} $out_R2{$_}\n";
		push @all,$cp_sh;
	}else{
		next;
	}
}

open my $whole_sh,'>',"cat_whole_work.sh";
print $whole_sh "WORKDIR=\"$dir\"\n";
print $whole_sh "for i in @all ; do\n";
print $whole_sh 'echo "#! /bin/bash'."\n";
print $whole_sh "#PBS -N \$i\n";
print $whole_sh '#PBS -q node'."\n";
print $whole_sh '#PBS -l nodes=1:'."ppn\=1\n";
print $whole_sh '#PBS -j oe'."\n\n";
print $whole_sh "cd \$WORKDIR\n";
print $whole_sh 'sh ${WORKDIR}/$i" > $i.pbs'."\n";
print $whole_sh "ssh mgmt01.catb.org.cn \"cd \$WORKDIR ;qsub \$i.pbs \"\n";
print $whole_sh "done\n";
