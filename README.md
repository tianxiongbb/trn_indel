# trn_indel
Pipeline for transposon insertion or deletion detection using DNA-seq data.
trn_indel contains 3 procedures:
1. Mapping sequencing data to genome via bwa-mem with soft clipping
2. Detecting transposon insertion or deletion by ![TEMP](https://github.com/JialiUMassWengLab/TEMP "zlab TEMP") (Author: Jiali Zhuang (jiali.zhuang@umassmed.edu) and Jie Wang (jie.wangj@umassmed.edu) Weng Lab, University of Massachusetts Medical School, Worcester, MA, USA)
3. Calculating transposon insertion or deletion rate and make bed file for visulization
***
## installation
<<<<<<< HEAD
For easy install, run install.sh in *trn_indel* folder after download and unzip the source code. It will add all the scripts needed into your PATH. Also, it will download several big transposon.bed file to the annotation fold. After installation, please use `source ~/.bashrc` or re-load the server.
After this, simple use `trn_indel.sh` to run the pipeline.
***
## usage
trn_indel <options> [-l left.fq] [-r right.fq] [-g genome]
optional arguments:
    -s fragment size in DNAseq. --default: 500
    -p prefix name for output files. trn_indel will creat a fold named prefix and write all the result in it. --default: ./result
    -c CPU number used for pipeline. --default: 1
    -f If set, trn_indel will just use both ends of transposon sequence for indel detection. This can reduce the effect of artificial bias by removing reads mapping to genome and middle of transposon which suppose not to be so long. default: unset
    -I bwa mem index for genome mapping. --default: program_path/annotation/genome/bwa_index/genome
    -h show help information.
***
## output
trn_indel gives many output which the most important three one is **xxx.insertion.refined.bp.summary**, **xxx.frequency** and **xxx.locus**
1. xxx.insertion.refined.bp.summary: please see ![TEMP](https://github.com/JialiUMassWengLab/TEMP "zlab TEMP") for details
2. xxx.frequency: the insertion frequency for each transposon seperated into three types -- 1p1, 2p, singleton
3. xxx.locus: the insertion locus number for each transposon seperated into three types -- 1p1, 2p, singleton


## contact
please send questions or bugs to yutianxiong@gmail.com
