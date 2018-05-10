import pandas as pd
import boto3
import botocore
import io


bcell_ids = pd.read_csv('maca_bcell_or_children_ids.csv', squeeze=True)
bcell_ids_dashes = bcell_ids.str.replace('.', '-')

s3 = boto3.resource('s3')
bucket = s3.Bucket('czbiohub-maca')

remux_data = bucket.objects.filter(Prefix='remux_data/')

fastqs = [x for x in remux_data if x.key.endswith('fastq.gz')]

def is_bcell_fastq(key):
    basename = key.key.split('/')
    return bcell_ids_dashes.str.startswith(basename).any()

bcell_fastqs = [x for x in fastqs if is_bcell_fastq(x)]


### Serial download

for bcell_fastq in bcell_fastqs:
    bucket.download_file(bcell_fastq)


### Parallelized

import threading


def download(key):
    s3 = boto3.resource('s3')
    bucket = s3.Bucket('czbiohub-maca')
    bucket.download_file(key)


bcell_fastqs = filter(is_bcell_fastq, bucket.objects.all())

for bcell_fastq in bcell_fastqs:
    t = threading.Thread(target=download, args=(bcell_fastq,)).start()
