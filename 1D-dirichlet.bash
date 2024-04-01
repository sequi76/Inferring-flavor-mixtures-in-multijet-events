#!/usr/bin/bash
name="1D01-03-2024.17.05Dr"
nsamples=1000
nwarmups=1000
nchains=4
nthreads=18
seed=10000
adapt=0.9
max_depth=15
models/dirichlet/1D-dirichlet sample num_samples=$nsamples num_warmup=$nwarmups num_chains=$nchains adapt delta=$adapt algorithm=hmc engine=nuts max_depth=$max_depth data file=models/dirichlet/$name.json num_threads=$nthreads output file=models/notebooks/results/"$name"-results.csv diagnostic_file=models/notebooks/results/"$name"-diagnostic.csv random seed=$seed
