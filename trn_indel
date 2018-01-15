#!/bin/bash

<<<<<<< HEAD
help_info(){
echo -e "\033[40;33;1m"
cat << EOF
Author: Tianxing Yu / Bear
usage:
trn_indel <options> [-l left.fq] [-r right.fq] [-g genome]
optional arguments:
    -s fragment size in DNAseq. --default: 500
    -p prefix name for output files. trn_indel will creat a fold named prefix and write all the result in it. --default: ./result
    -c CPU number used for pipeline. --default: 1
    -f If set, trn_indel will just use both ends of transposon sequence for indel detection. This can reduce the effect of artificial bias by removing reads mapping to genome and middle of transposon which suppose not to be so long. default: unset
    -I bwa mem index for genome mapping. --default: program_path/annotation/genome/bwa_index/genome
    -h show help information.
EOF
echo -e "\033[0m"
}
if [ $# -lt 1 ];then
	help_info
	exit 1
fi

# read parameters
PATH_PRO=$(dirname `readlink -f $0`)
FIX=0
FRAGMENT_SIZE=500
PREFIX=./result
CPU=1
while getopts "l:r:g:s:p:c:fI:h" OPTION; do
	case $OPTION in
		h)	help_info && exit 0;;
		l)	LEFT=`readlink -f ${OPTARG}`;;
		r)	RIGTH=`readlink -f ${OPTARG}`;;
		g)	GENOME=${OPTARG};;
		s)	FRAGMENT_SIZE=${OPTARG};;
		p)	PREFIX=${OPTARG};;
		c)	CPU=${OPTARG};;
		f)	FIX=1;;
		I)	BWA_INDEX=`readlink -f ${OPTARG}`;;
	esac
done
if [ -s $BWA_INDEX ];then
	BWA_INDEX=${PATH_PRO}/annotation/${GENOME}/bwa_index/genome
fi
TRN_FA=${PATH_PRO}/annotation/${GENOME}/transposon.fa
TRN_BED=${PATH_PRO}/annotation/${GENOME}/rmsk.bed
TRN_SIZE=${PATH_PRO}/annotation/${GENOME}/transposon.size

# check parameters and denpendency
[ ! -s ${LEFT} ] && echo0 0 "Error: left.fq error. There is no file in "${LEFT}". Abort!" && exit 1
[ ! -s ${RIGHT} ] && echo0 0 "Error: right.fq error. There is no file in "${LEFT}". Abort!" && exit 1
[ ! -s $TRN_FA ] && echo0 0 "Error: transposon.fa error. There is no file in "${TRN_FA}". Please check if there is "$GENOME" and have transposon.fa file in it. Abort!" && exit 1
[ ! -s $TRN_BED ] && echo0 0 "Error: rmsk.bed error. There is no file in "${TRN_FA}". Please check if there is "$GENOME" and have transposon.fa file in it. Abort!" && exit 1
[ ! -s $TRN_SIZE ] && echo0 0 "Warning: transposon.size error. There is no file in "${TRN_FA}". Please check if there is "$GENOME" and have transposon.fa file in it. Create a new one!" && awk 'BEGIN{FS=OFS="\t"} {if($1~/^>/){name=substr($1,2);a[name]=0}else{a[name]+=length($1)}} END{for(i in a){print i,a[i]}}' ${TRN_FA} > ${TRN_SIZE}
[ ! -w `dirname $PREFIX` ] && echo0 0 "Error: Sorry, you do not have write authority in "${PREFIX}". Please use another -p parameter. Abort!" && exit 1

function checkTools(){
	if [ `which $1` ];then
		echo0 3 `which $1`
	else
		echo0 0 $1" not found, please install it or add it into your PATH!"
		exit 1
	fi
}
checkTools bwa
checkTools samtools

# prepare
echo0 1 "trn_indel start......"
echo0 2 "output will be in "$PREFIX
mkdir $PREFIX
cd $PREFIX
PREFIX=`basename ${PREFIX}`

# map to genome and make indexed+sorted bam
echo0 2 "map "${LEFT}" and "${RIGHT}" to genome via bwa mem"
bwa mem -T 0 -Y -t ${CPU} ${BWA_INDEX} $LEFT $RIGHT > ${PREFIX}.sam
echo0 2 "sam to indexed+sorted bam"
samtools view -bhS ${PREFIX}.sam > ${PREFIX}.bam
samtools sort -@ ${CPU} ${PREFIX}.bam ${PREFIX}.sorted
rm ${PREFIX}.sam ${PREFIX}.bam
samtools index ${PREFIX}.sorted.bam
# if artificial bias is set to fixed, chop fragment size from both end of each transposon for TEMP
echo0 2 "chop "${FRAGMENT_SIZE}"bp from both end of each transposon to remove to artificial bias"
if [ ${FIX} -gt 0 ];then
	awk -v fl=$FRAGMENT_SIZE 'BEGIN{FS=OFS="\t"} {if($1~/^>/){name=substr($1,2);a[name]=""}else{a[name]=a[name]""$1}} END{for(i in a){print ">"i;if(length(a[i])<=2*fl){print a[i]}else{print substr(a[i],1,fl)""substr(a[i],length(a[i])-fl+1)}}}' ${TRN_FA} > chopped.trn.fa
	TRN_FA=chopped.trn.fa
fi
# run TEMP insertion
echo0 2 "run TEMP insertion"
${PATH_PRO}/TEMP/TEMP_Insertion.sh -i ${PREFIX}.sorted.bam -s ${PATH_PRO}/TEMP/ -r ${TRN_FA} -c ${CPU} -t ${TRN_BED} -f $FRAGMENT_SIZE -x 5 > ${PREFIX}.TEMP.log 2>&1
# summary TEMP result
echo0 2 "summary TEMP result to "${PREFIX}".frequency and "${PREFIX}".locus"
awk 'BEGIN{FS=OFS="\t";a["sense"]="+";a["antisense"]="-"} {if(NR>1){print $1,$2,${PREFIX},$4,$6,a[$5],$8}}' ${PREFIX}.insertion.refined.bp.summary > ${PREFIX}.bed7 
TEMP_bed7_summary.sh ${PREFIX}.bed7 ${TRN_SIZE}
# remove useless files
[ -f chopped.trn.fa ] && rm chopped.trn.fa
echo0 1 "trn_indel finished!!!"
=======
if [ $# -lt 3 ];then
	echo0 1 $0" left.fq rigth.fq out.prefix CPU out.dir if_fixed_by_te_cor(0|1)"
	exit 1
fi

#configures
TE_FA=/data/tusers/yutianx/tongji2/Software/piPipes/common/dm3/dm3.transposon.fa
BWA_INDEX=/data/tusers/yutianx/tongji2/Annotation/Index/dm3_bwa/genome
BOWTIE2_INDEX=/data/tusers/yutianx/tongji2/Annotation/Index/dm3_bowtie2/genome
TE_BED=/data/tusers/yutianx/tongji2/Software/piPipes/common/dm3/dm3.transposon.rm.bed
FRAGMENT_SIZE=300

#run
LEFT=`readlink -f $1`
RIGHT=`readlink -f $2`
mkdir $5
cd $5
bwa mem -T 0 -Y -t $4 ${BWA_INDEX} $LEFT $RIGHT > $3.sam
#bowtie2 -x ${BOWTIE2_INDEX} -1 $LEFT -2 $RIGHT --local -S $3.sam --un-conc $3.unpair.uniq.fastq -p 4 > log_$3_bowtie2 2>&1
#bwa aln -n 3 -l 100 -R 10000 -t $4 /data/tusers/yutianx/tongji2/Annotation/Index/dm3_bwa/genome $1 > $3.1.sai
#bwa aln -n 3 -l 100 -R 10000 -t $4 /data/tusers/yutianx/tongji2/Annotation/Index/dm3_bwa/genome $1 > $3.2.sai
#bwa sampe /data/tusers/yutianx/tongji2/Annotation/Index/dm3_bwa/genome $3.1.sai $3.2.sai $1 $2 > $3.sam
samtools view -bhS $3.sam > $3.bam
samtools sort -@ $4 $3.bam $3.sorted
rm $3.sam $3.bam
samtools index $3.sorted.bam
if [ $6 -gt 0 ];then
	awk -v fl=$FRAGMENT_SIZE 'BEGIN{FS=OFS="\t"} {if($1~/^>/){name=substr($1,2);a[name]=""}else{a[name]=a[name]""$1}} END{for(i in a){print ">"i;if(length(a[i])<=2*fl){print a[i]}else{print substr(a[i],1,fl)""substr(a[i],length(a[i])-fl+1)}}}' ${TE_FA} > chopped.te.fa
	TE_FA=chopped.te.fa
fi
/data/tusers/yutianx/tongji2/Software/TEMP/scripts/TEMP_Insertion.sh -i $3.sorted.bam -s /data/tusers/yutianx/tongji2/Software/TEMP/scripts/ -r ${TE_FA} -c $4 -t ${TE_BED} -f $FRAGMENT_SIZE -x 5
awk 'BEGIN{FS=OFS="\t"} {if($1~/^>/){name=substr($1,2);a[name]=0}else{a[name]+=length($1)}} END{for(i in a){print i,a[i]}}' ${TE_FA} > tmp.te.size
awk 'BEGIN{FS=OFS="\t";a["sense"]="+";a["antisense"]="-"} {if(NR>1){print $1,$2,$3,$4,$6,a[$5],$8}}' ${3}.insertion.refined.bp.summary > ${3}.final.bed7 
awk 'BEGIN{FS=OFS="\t"} {if(NR==FNR){a[$4]["all"]+=$7;a[$4][$5]+=$7}else{print $1,a[$1]["all"]?a[$1]["all"]:0,a[$1]["1p1"]?a[$1]["1p1"]:0,a[$1]["2p"]?a[$1]["2p"]:0,a[$1]["singleton"]?a[$1]["singleton"]:0}}' ${3}.final.bed7 tmp.te.size > ${3}.final.result




>>>>>>> a26ddd761444f2c4a80f124eff08a130d9a50178
