import os
import shlex
import subprocess

import click

"""
bracer assemble -p 16 --species Mmus --config_file /mnt/data/fastq/bracer.conf \
    --no_trimming  \
    P9-MAA001889-3_38_F-1-1_S239_no-trimming \
    /mnt/data/bracer_output/ \
    /mnt/data/fastq/P9-MAA001889-3_38_F-1-1_S239_R1_001.fastq.gz \
    /mnt/data/fastq/P9-MAA001889-3_38_F-1-1_S239_R2_001.fastq.gz
"""


def maybe_make_directory(folder):
    try:
        os.makedirs(folder)
    except OSError:
        pass


@click.command()
@click.argument('fastq_gzs', nargs=-1)
@click.option('--config-file', default='/mnt/data/fastq/bracer.conf',
              type=str)
@click.option('--species', default="Mmus", type=str)
@click.option('--output-folder', default="/mnt/data/bracer_output_v2/",
              type=str)
@click.option('--n-processes', default=16, type=int)
def cli(fastq_gzs, config_file, species, output_folder, n_processes):
    for fastq_gz in fastq_gzs:
        # Only operate on R1s to avoid duplication
        if "_R2_" in fastq_gz:
            continue
        read1 = fastq_gz
        read2 = fastq_gz.replace('_R1_', '_R2_')

        sample_id = os.path.basename(read1).split('_R1_')[0]

        command = f'bracer assemble ' \
                  f'-p {n_processes} ' \
                  f'--config_file {config_file} ' \
                   '--no_trimming ' \
                  f'--species {species} ' \
                  f'{sample_id} ' \
                  f'{output_folder} ' \
                  f'{read1} ' \
                  f'{read2} '
        print(command)
        command = shlex.split(command)

        sample_dir = os.path.join(output_folder, sample_id)
        maybe_make_directory(sample_dir)

        stdout = os.path.join(sample_dir, 'stdout.txt')
        stderr = os.path.join(sample_dir, 'stderr.txt')


        with open(stdout, 'w') as file_out:
            with open(stderr, 'w') as file_err:
                process = subprocess.Popen(command, stdout=file_out,
                                           stderr=file_err)
                (output, err) = process.communicate()
                print('output:', output)
                print('err:', err)
                process_status = process.wait()
                print('process_status:', process_status)


if __name__ == '__main__':
    cli()
