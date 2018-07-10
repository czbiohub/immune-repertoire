## TCR Assembly with TRACER         

`Author: Lincoln Harris`          
`Date: July 2018`

Repo for shell scripts I used to run Tracer on a bunch of putative tCells. Currently, requires you to spin up a VM with a lot of memory and a lot of disk space, download all of your tCells to the root volume, run `tracer_assemble_multi.sh`, followed by `tracer_summarize.sh`. You also need to install docker on your system before you do anything, and make sure you download teichlab/tracer. I ran this on a Ubuntu16.04 VM. 