#!/bin/bash -x
# TEMP (Transposable Element Movement present in a Population)
# 2013-06-14
# Jiali Zhuang(jiali.zhuang@umassmed.edu)
# Zhiping Weng Lab
# Programs in Bioinformatics and Integrative Biology
# University of Massachusetts Medical School

#usage function
usage() {
echo -en "\e[1;36m"
cat <<EOF

usage: $0 -i input_file.sorted.bam -s scripts_directory -o output_directory -r transposon_database.fa -t annotated_TEs.bed -m MISMATCH -f fragment_size -c CPUs -h -F

TEMP is a software package for detecting transposable elements (TEs) 
insertions and excisions from pooled high-throughput sequencing data. 
Please send questions, suggestions and bug reports to:
jiali.zhuang@umassmed.edu

Options:
        -i     Input file in bam format with full path. Please sort and index the file before calling this program. 
               Sorting and indexing can be done by 'samtools sort' and 'samtools index'
        -s     Directory where all the scripts are
        -o     Path to output directory. Default is current directory
        -r     Transposon sequence database in fasta format with full path
        -t     Annotated TEs in BED6 format with full path. Detected insertions that overlap with annoated TEs will be filtered. 
        -u     TE families annotations. If supplied detected insertions overlap with annotated TE of the same family will be filtered. Only use with -t.
        -m     Number of mismatch allowed when mapping to TE concensus sequences. Default is 3
        -x     The minimum score difference between the best hit and the second best hit for considering a read as uniquely mapped. For BWA mem. 
        -f     An integer specifying the length of the fragments (inserts) of the library. Default is 500
        -c     An integer specifying the number of CPUs used. Default is 8
        -h     Show help message

EOF
echo -en "\e[0m"
}

# taking options
while getopts "hi:c:f:m:o:r:s:t:u:x:F" OPTION
do
        case $OPTION in
                h)
                        usage && exit 1
		;;
                i)
                        BAM=`readlink -f $OPTARG`
		;;
	        f)
		        INSERT=$OPTARG
		;;
	        m)
		        MM=$OPTARG
		;;
                o)
                        OUTDIR=$OPTARG
                ;;
                c)
                        CPU=$OPTARG
                ;;
                s)
                        BINDIR=$OPTARG
                ;;
	        r)
		        TESEQ=$OPTARG
		;;
	        t)
                        ANNO=$OPTARG
                ;;
                u)
                        FAMI=$OPTARG
                ;;
	        x)
		        SCORE=$OPTARG
		;;
                ?)
                        usage && exit 1
                ;;
        esac
done

if [[ -z $BAM ]] || [[ -z $BINDIR ]] || [[ -z $TESEQ ]]
then
        usage && exit 1
fi
[ ! -z "${CPU##*[!0-9]*}" ] || CPU=8
[ ! -z "${INSERT##*[!0-9]*}" ] || INSERT=500
[ ! -z "${MM##*[!0-9]*}" ] || MM=3
[ ! -z "${SCORE##*[!0-9]*}" ] || SCORE=0
[ ! -z $OUTDIR ]  || OUTDIR=$PWD
[ ! -z $FILTER ]  || FILTER=0
mkdir -p "${OUTDIR}" || echo -e "\e[1;31mWarning: Cannot create directory ${OUTDIR}. Using the direcory of input fastq file\e[0m"
cd ${OUTDIR} || echo -e "\e[1;31mError: Cannot access directory ${OUTDIR}... Exiting...\e[0m" || exit 1
touch ${OUTDIR}/.writting_permission && rm -rf ${OUTDIR}/.writting_permission || echo -e "\e[1;31mError: Cannot write in directory ${OUTDIR}... Exiting...\e[0m" || exit 1

function checkExist {
        echo -ne "\e[1;32m\"${1}\" is using: \e[0m" && which "$1"
        [[ $? != 0 ]] && echo -e "\e[1;36mError: cannot find software/function ${1}! Please make sure that you have installed the pipeline correctly.\nExiting...\e[0m" && exit 1
}
echo -e "\e[1;35mTesting required softwares/scripts:\e[0m"
checkExist "echo"
checkExist "rm"
checkExist "mkdir"
checkExist "date"
checkExist "mv"
checkExist "sort"
checkExist "touch"
checkExist "awk"
checkExist "grep"
checkExist "bwa"
checkExist "samtools"
echo -e "\e[1;35mDone with testing required softwares/scripts, starting pipeline...\e[0m"

cp $TESEQ ./
name=`basename $BAM`
te=`basename $TESEQ`
i=${name/.sorted.bam/}
echo $name
echo $i
if [[ ! -s $name ]]
then
    cp $BAM ./
fi
if [[ ! -s $name.bai ]]
then cp $BAM.bai ./
fi

# Get the mate seq of the uniq-unpaired reads
samtools view -F 0x2  $name > $i.unpair.sam
if [[ $SCORE -eq 0 ]]
then
    perl $BINDIR/pickUniqPairFastq.pl $i.unpair.sam $i.unpair.uniq
    perl $BINDIR/pickUniqPos.pl $i.unpair.sam > $i.unpair.uniq.bed
else
    perl $BINDIR/pickUniqPairFastq_MEM.pl $i.unpair.sam $i.unpair.uniq $SCORE
    perl $BINDIR/pickUniqPos_MEM.pl $i.unpair.sam $SCORE > $i.unpair.uniq.bed 
fi

# Map to transposons
bwa index -a is $te
bwa aln -t $CPU -n $MM -l 100 -R 1000 $te $i.unpair.uniq.1.fastq > $i.unpair.uniq.1.sai
bwa aln -t $CPU -n $MM -l 100 -R 1000 $te $i.unpair.uniq.2.fastq > $i.unpair.uniq.2.sai
bwa sampe -P $te $i.unpair.uniq.1.sai $i.unpair.uniq.2.sai $i.unpair.uniq.1.fastq $i.unpair.uniq.2.fastq > $i.unpair.uniq.transposons.sam


#Summary
#awk 'BEGIN{FS=OFS="\t"} {if($1~/^>/){name=substr($1,2);a[name]=0}else{a[name]+=length($1)}} END{for(i in a){print i,a[i]}}' $te > tmp.te.size
samtools view -hSF 0x2 $i.unpair.uniq.transposons.sam > $i.unpair.uniq.transposons.unpair.sam
perl $BINDIR/pickUniqMate.pl $i.unpair.uniq.transposons.unpair.sam $i.unpair.uniq.bed > $i.unpair.uniq.transposons.bed
cp $i.unpair.uniq.transposons.bed $i.unpair.uniq.transposons.filtered.bed
#awk -v fl=$INSERT 'BEGIN{FS=OFS="\t"} {if(NR==FNR){tl[$1]=$2}else{o="";split($5,a,";");for(i in a){split(a[i],b,",");if(b[1]){if((b[2]<0 && (b[2]>-fl || b[2]<(fl-tl[b[1]]))) || (b[2]>0 && (b[2]>(tl[b[1]]-fl) || b[2]<fl))){o=o""a[i]";"}}};if(o){$5=o;print $0}}}' tmp.te.size $i.unpair.uniq.transposons.bed > $i.unpair.uniq.transposons.filtered.bed

#Prepare for insertion breakpoints identification
awk -F "\t" -v sample=$i '{OFS="\t"; print $1,$2,$3,sample,$5,$6}' $i.unpair.uniq.transposons.filtered.bed >> tmp
perl $BINDIR/mergeTagsWithoutGap.pl tmp > $i.uniq.transposons.filtered.woGap.bed
perl $BINDIR/mergeTagsWithGap.pl $i.uniq.transposons.filtered.woGap.bed $INSERT > $i.uniq.transposons.filtered.wGap.bed
rm tmp
perl $BINDIR/get_class.pl $i.uniq.transposons.filtered.wGap.bed $i > $i.uniq.transposons.filtered.wGap.class.bed
perl $BINDIR/make.bp.bed.pl $i.uniq.transposons.filtered.wGap.class.bed $ANNO $FAMI

#rm $i.unpair.sam $i.unpair.uniq.bed $i.unpair.uniq.?.fastq $i.unpair.uniq.?.sai 
#rm $i.unpair.uniq.transposons.sam $i.unpair.uniq.transposons.unpair.sam $i.uniq.transposons.filtered.woGap.bed $i.uniq.transposons.filtered.wGap.bed


#Detect insertion breakpoints using soft-clipping information
perl $BINDIR/pickClippedFastq.pl $i $te
perl $BINDIR/refine_breakpoint.in.pl


#Estimate insertion frequencies
perl $BINDIR/pickOverlapPair.in.pl $i.insertion.refined.bp $INSERT > $i.insertion.refined.bp.summary


################################
##End of processing insertions##
################################

