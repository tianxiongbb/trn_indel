#!/share/bin/perl
use Bio::Seq;

die "perl $0 <sam> <output prefix>\n" if @ARGV<1;

open m1,">$ARGV[1].1.fastq";
open m2,">$ARGV[1].2.fastq";

open in,$ARGV[0];
my %pe;
while(<in>)
{
	chomp;
	my @f=split/\t/,$_,12;
	## read number 1 or 2
	#my ($rnum)=$f[1]=~/(\d)$/;
        my $rnum=1;
        if (($f[1] & 128) == 128) {$rnum=2;}

	## XT:A:* 
	my ($xt)=$f[11]=~/XT:A:(.)/;

	## revcom the read mapped to the reverse strand
	if(($f[1] & 16) == 16)
	{
		my $seq=Bio::Seq->new(-seq=>$f[9]);
		$f[9]=$seq->revcom->seq;
		$f[10]=reverse $f[10];
	}
	if (($rnum == 1) || ($rnum == 2))
	{
	    ${$pe{$f[0]}}[$rnum-1]=[$xt,$f[9],$f[10]];
	}
}
close in;

foreach my $id (keys %pe)
{
	my @rid=@{$pe{$id}};
	if (($rid[0][1] ne "") && ($rid[1][1] ne "") && (($rid[0][0] eq "U" || $rid[1][0] eq "U")))
	{
		print m2 "@"."$id/2","\n",$rid[1][1],"\n","+$id/2","\n",$rid[1][2],"\n";
		print m1 "@"."$id/1","\n",$rid[0][1],"\n","+$id/1","\n",$rid[0][2],"\n";
	}
}
close m1;
close m2;
