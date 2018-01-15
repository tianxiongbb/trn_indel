#!/bin/bash

PATH_PRO=$PWD"/"`dirname $0`
echo -e "# added by trn_indel installer\nexport PATH=${PATH_PRO}:\$PATH" >> ~/.bashrc
wget http://users.wenglab.org/yutianx/annotation/mm10/transposon.bed.gz
mv transposon.bed.gz ${PATH_PRO}/annotation/mm10/
wget http://users.wenglab.org/yutianx/annotation/phaCin0/transposon.bed.gz
mv transposon.bed.gz ${PATH_PRO}/annotation/phaCin0/
gunzip ${PATH_PRO}/annotation/*/*.bed.gz
