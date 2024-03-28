#!/usr/bin/bash
name="28-02-2024.22.48Dr"
nsamples=2000
nwarmups=2000
nchains=4
nthreads=18
seed=30
adapt=0.9
max_depth=13
models/dirichlet/dirichlet sample num_samples=$nsamples num_warmup=$nwarmups num_chains=$nchains adapt delta=$adapt algorithm=hmc engine=nuts max_depth=$max_depth data file=models/dirichlet/$name.json num_threads=$nthreads output file=models/notebooks/results/"$name"-results.csv diagnostic_file=models/notebooks/results/"$name"-diagnostic.csv random seed=$seed
