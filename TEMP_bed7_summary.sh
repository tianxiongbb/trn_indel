#!/bin/bash

if [ $# -lt 2 ];then
	echo0 1 $0" in.bed7 TE.size"
	exit 1
fi

awk 'BEGIN{FS=OFS="\t";print "\tall\t1p1\t2p\tsingleton"} {if(NR==FNR){a[$4]["all"]+=$7;a[$4][$5]+=$7}else{print $1,a[$1]["all"]/1,a[$1]["1p1"]/1,a[$1]["2p"]/1,a[$1]["singleton"]/1}}' $1 $2 > ${1%.bed7}.frequency 
awk 'BEGIN{FS=OFS="\t";print "\tall\t1p1\t2p\tsingleton"} {if(NR==FNR){a[$4]["all"]++;a[$4][$5]++}else{print $1,a[$1]["all"]/1,a[$1]["1p1"]/1,a[$1]["2p"]/1,a[$1]["singleton"]/1}}' $1 $2 > ${1%.bed7}.locus 
