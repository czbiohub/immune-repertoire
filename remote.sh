cd ~/ && git clone https://github.com/olgabot/rcfiles && cp rcfiles/.* .
screen

conda create --yes -n python2.7-env python=2.7 biopython matplotlib scipy numpy pandas seaborn
source activate python2.7-env
# Force linking of env python2
sudo ln -s /home/ubuntu/anaconda/envs/python2.7-env/bin/python2.7 /usr/bin/python2

sudo apt install cmake

git clone https://github.com/yana-safonova/ig_repertoire_constructor/
cd ig_repertoire_constructor
make
./igrec.py --test
./barcoded_igrec.py --test


# Get Cells labeled as "B cell" (or a child, e.g. "immature B cell") in MACA data
cd
git clone https://github.com/czbiohub/olgabot-aws-scratch/
cd ~/olgabot-aws-scratch
git checkout igrec
cd /mnt/data
cp ~/olgabot-aws-scratch/maca_bcell_or_children_ids.csv  .


cd /mnt/data
mkdir krista
cd krista
sudo aws s3 cp --recursive \
  s3://czbiohub-seqbot/fastqs/180128_M05295_0078_000000000-BJNBT .

DATA_DIR=/mnt/data/krista/rawdata


# Make subset of first 10k reads
sudo head -n 40000 $DATA_DIR/IgSeqBX1_S1_R1_001.fastq > $DATA_DIR/IgSeqBX1_S1_R1_001_first10k.fastq
sudo head -n 40000 $DATA_DIR/IgSeqBX1_S1_R2_001.fastq > $DATA_DIR/IgSeqBX1_S1_R2_001_first10k.fastq

./run_barcoded_igrec.py $DATA_DIR/IgSeqBX1_S1_R1_001_first10k.fastq \
    $DATA_DIR/IgSeqBX1_S1_R2_001_first10k.fastq barcoded_igrec_first10k

# Make subset of first 100k reads
sudo head -n 400000 $DATA_DIR/IgSeqBX1_S1_R1_001.fastq > $DATA_DIR/IgSeqBX1_S1_R1_001_first100k.fastq
sudo head -n 400000 $DATA_DIR/IgSeqBX1_S1_R2_001.fastq > $DATA_DIR/IgSeqBX1_S1_R2_001_first100k.fastq

./run_barcoded_igrec.py $DATA_DIR/IgSeqBX1_S1_R1_001_first100k.fastq \
    $DATA_DIR/IgSeqBX1_S1_R2_001_first100k.fastq barcoded_igrec_first100k

# Make subset of first 1 million reads
sudo head -n 4000000 $DATA_DIR/IgSeqBX1_S1_R1_001.fastq > $DATA_DIR/IgSeqBX1_S1_R1_001_first1M.fastq
sudo head -n 4000000 $DATA_DIR/IgSeqBX1_S1_R2_001.fastq > $DATA_DIR/IgSeqBX1_S1_R2_001_first1M.fastq

./run_barcoded_igrec.py $DATA_DIR/IgSeqBX1_S1_R1_001_first1M.fastq \
    $DATA_DIR/IgSeqBX1_S1_R2_001_first1M.fastq barcoded_igrec_first1M


source activate python2.7-env
/home/ubuntu/ig_repertoire_constructor/barcoded_igrec.py \
  -1 $DATA_DIR/IgSeqBX1_S1_R1_001.fastq -2 $DATA_DIR/IgSeqBX1_S1_R2_001.fastq \
  --output barcoded_igrec --loci IGH


## Run non-barcoded igrec
source activate python2.7-env
python ./run_igrec.py $DATA_DIR/IgSeqBX1_S1_R1_001_first100k.fastq \
    $DATA_DIR/IgSeqBX1_S1_R2_001_first100k.fastq nonbarcoded_igrec_first1M



## Run ChangeO and Alakazam through Immcantation docker image
sudo apt install --yes docker.io
docker pull kleinstein/immcantation:1.7.0


## Install Jupyterlab
conda install --yes jupyter  pandas matplotlib seaborn scikit-learn
jupyter serverextension enable --py jupyterlab --sys-prefix


## Convert barcode-containing fastqs to something igrec understands
cd /mnt/data/presto/output
python -m pdb ~/olgabot-aws-scratch/format_barcodes.py --time /mnt/data/presto/output/BX-R1_primers-pass_pair-pass.fastq 1 > /mnt/data/fastq/BX-R1_primers-pass_underscore_separated.fastq
python -m pdb ~/olgabot-aws-scratch/format_barcodes.py --time /mnt/data/presto/output/BX-R2_primers-pass_pair-pass.fastq 2 > /mnt/data/fastq/BX-R2_primers-pass_underscore_separated.fastq


python run_igrec.py --barcoded \
    /mnt/data/fastq/BX-R1_primers-pass_underscore_separated.fastq \
    /mnt/data/fastq/BX-R2_primers-pass_underscore_separated.fastq \
    igrec_on_presto_primers_pass_underscore_separated_v2


## Use Go to change the fastqs
cd format_barcodes
go build
./format_barcodes /mnt/data/presto/output/BX-R1_primers-pass_pair-pass_first3.fastq

# Could also not build:
# go run main.go /mnt/data/presto/output/BX-R1_primers-pass_pair-pass_first3.fastq
# 2:N:0:0|SEQORIENT=F|PRIMER=RT_IgM_long_12N|BARCODE=TCGGAAAT,ACGGCAGA
# 2:N:0:0|SEQORIENT=F|PRIMER=RT_IgM_long_12N|BARCODE=TCTTGTCT,ACGGTATA
# 2:N:0:0|SEQORIENT=F|PRIMER=RT_IgM_long_12N|BARCODE=AATCCCGT,GGCAATTC


# 20 min in serial in Python (!!)
# ubuntu@olgabot-igrec-m4  git pull && python ~/olgabot-aws-scratch/format_barcodes.py --time /mnt/data/presto/output/BX-R1_primers-pass_pair-pass.fastq 1 > /mnt/data/fastq/BX-R1_primers-pass_underscore_separated.fastq
# Current branch igrec is up to date.
# 2018-04-17 05:06:27
# 2018-04-17 05:26:33