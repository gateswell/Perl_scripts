##计算不同深度对应的覆盖度和平均深度
##Usage: perl path/to/samtools_depth_cvg_calculate.pl <depth.txt>
##AUTHOR: Cao Shuhuan
#!/usr/bin/perl
use strict;
open my $fh,$ARGV[0];
my @depth_filter=(1,10,20,50,100);
#my @depth_filter=(1,10,20,25,30,40,50,60,70,75,80,90,100,110,120,125,130,140,150,160,170,175,180,190,200,225,250,275,300,350,400,450,500,550,600,650,700,750,800,900,1000);
my (%depth_hash,%cvg_hash,$pos,$sum_depth);
$ARGV[0]=~ /(\w+)\_S(\w+)_depth\.txt/;
my $name = $1;
while(<$fh>){
	my @tmp = split(/\t/,$_);
	my $depth = $tmp[2];
	foreach my $dep(@depth_filter){
		if ($depth >= $dep){
			$depth_hash{$dep}++;
		}
		else {next;}
	}
	$pos ++ if $_;
	$sum_depth += $depth;
} 
close $fh;
=pod
print "mean_depth:\t",$sum_depth/$pos,"\n";
print "\n";
print "depth\tcoverage\n";
=cut
my($d10,$d20,$d50,$d100);
foreach my $dep(@depth_filter){
	$cvg_hash{$dep}= $depth_hash{$dep}/$pos;
	#printf ">= %d\t%.2f\n",$dep,$cvg_hash{$dep}*100;	
}
$d10 = $cvg_hash{'10'};
$d20 = $cvg_hash{'20'};
$d50 = $cvg_hash{'50'};
$d100 = $cvg_hash{'100'};
my $mean_depth = $sum_depth/$pos;
print "sampleID\t\t\tQ30\tMean_depth\t\>10x\t\>20x\t\>50x\t\>100x\n";
printf "20%s\t\t\t\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n",$name,$mean_depth,$d10*100,$d20*100,$d50*100,$d100*100;
