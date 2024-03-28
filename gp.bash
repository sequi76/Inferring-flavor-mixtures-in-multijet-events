#!/usr/bin/bash
name="24-02-2024.20.17hs"
results_dir="models/notebooks/results"
if ls $results_dir/$name*csv 1> /dev/null 2>&1; then
        echo "File exsits!"
        echo "pelotudooooo"
        exit 1
else
        echo 'ok seguimos'
        nsamples=1000
        nwarmups=1000
        nchains=4
        nthreads=18
        seed=30
        adapt=0.8
        max_depth=15
        models/gp/gp1_no-correlation_parallel sample num_samples=$nsamples num_warmup=$nwarmups num_chains=$nchains adapt delta=$adapt algorithm=hmc engine=nuts max_depth=$max_depth data file=models/gp/$name.json num_threads=$nthreads output file="$results_dir"/"$name"-results.csv diagnostic_file="$results_dir"/"$name"-diagnostic.csv random seed=$seed
fi    
