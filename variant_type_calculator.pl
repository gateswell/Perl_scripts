##计算multianno.vcf中突变的各种类型数目
##Usage : perl path/to/variant_type_calculator.pl <vcf>
##AUTHOR: Cao Shuhuan
#!/usr/bin/perl 
use strict;
open my $csv,$ARGV[0];
my $name;
if($ARGV[0]=~/(.*)\/(\w+)\.hg19_multianno\.vcf/){
	$name = $2;
}
elsif($ARGV[0]=~/(\w+)\.hg19_multianno\.vcf/){
	$name = $1;
}
open my $result,'>',"$name\_variant_types_number.txt";
print $result "### $name ###\n";
#print $result "\n---Func.refGene---\n\n";
my(%Func_num,%syn_num,$total);
my($COSMIC_num,$Clinvar_num,$num_of_harm)=0;
while(<$csv>){
	next if /^#/;
	my @tmp = split (/\t/,$_);
	my @str = split (/\;/,$tmp[7]);
	my %hash;
	my ($value,$sum)=0;
	$total ++ if $_;
	foreach (@str){
		my ($keys,$value)=split(/\=/,$_);
		$hash{$keys}=$value;
		if($keys=~ /\bFunc.refGene/){
			$Func_num{$hash{$keys}}++;
		}
		if($keys=~ /ExonicFunc.refGene/){
			$syn_num{$hash{$keys}}++;
		}
	}
	if($hash{'COSMIC_FAT_score'}>= 0.5 && $hash{'COSMIC_FAT_score'} =~ /\d+/){
		$COSMIC_num ++;
	}
	if($hash{'CLINSIG'}=~/^Pathogenic/){
		$Clinvar_num ++;
	}
	if($hash{'SIFT_score'} =~ /\d+/ and $hash{'SIFT_score'}<=0.05 and $hash{'SIFT_score'}>=0){
		$value ++;
	}
	if($hash{'Polyphen2_HVAR_score'}>=0.909){
		$value ++;
	}
	if($hash{'LRT_pred'} eq 'D'){
		$value ++;
	}
	if($hash{'MutationTaster_pred'} eq 'A' or $hash{'MutationTaster_pred'} eq 'D'){
		$value ++;
	}
	if($hash{'MutationAssessor_pred'} eq "M|H"){
		$value ++;
	}
	if($hash{'MetaSVM_pred'} eq 'D'){
		$value ++;
	}
	if($hash{'MetaLR_pred'} eq 'D'){
		$value ++;
	}
	if($hash{'FATHMM_pred'} eq 'D'){
		$value ++;
	}
	if($hash{'PROVEAN_score'}<=-2.5){
		$value ++;
	}
	$sum += $value;
	if($sum >=1){
		$num_of_harm ++;
	}
}
my($intron_num,$ncRNA_intron,$exon_num,$splicing_num,$exsplic,$intergenic)=0;
foreach my $site(sort keys %Func_num){
	$intron_num = $Func_num{'intronic'};
	#$ncRNA_intron =  $Func_num{'ncRNA_intronic'};
	$exon_num  = $Func_num{'exonic'};
	$splicing_num = $Func_num{'splicing'};
	$exsplic = $Func_num{'exonic\x3bsplicing'};
	$intergenic = $Func_num{'intergenic'};
}
my $exon_total = $exon_num + $splicing_num + $exsplic;
my $intron_total= $intron_num;
my $inter_total = $intergenic;
print $result "\ntotal:\t$total\n";
print $result "exonic:\t$exon_total\n";
print $result "intron:\t$intron_total\n";
print $result "intergenic:\t$inter_total\n";
print $result "synonymous:\t$syn_num{'synonymous_SNV'}\n";
print $result "nonsynonymous:\t$syn_num{'nonsynonymous_SNV'}\n";
print $result "stopgain:\t$syn_num{'stopgain'}\n";
print $result "stoploss:\t$syn_num{'stoploss'}\n";
print $result "nonframeshift_insertion:\t$syn_num{'nonframeshift_insertion'}\n";
print $result "nonframeshift_deletion:\t$syn_num{'nonframeshift_deletion'}\n";
print $result "frameshift_insertion:\t$syn_num{'frameshift_insertion'}\n";
print $result "frameshift_deletion:\t$syn_num{'frameshift_deletion'}\n";
print $result "pathogenic_site:\t$num_of_harm\n";
print $result "COSMIC_pathogenic_site:\t$COSMIC_num\n";
print $result "Clinvar_pathogenic_site:\t$Clinvar_num\n";

close $csv;
close $result;
