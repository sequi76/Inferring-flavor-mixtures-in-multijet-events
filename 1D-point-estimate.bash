#!/usr/bin/bash
name="1D21-03-2024.17.04PE"
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
        seed=10
        adapt=0.9
        max_depth=15
        models/point-estimate/1D-point-estimate sample num_samples=$nsamples num_warmup=$nwarmups num_chains=$nchains adapt delta=$adapt algorithm=hmc engine=nuts max_depth=$max_depth data file=models/point-estimate/$name.json num_threads=$nthreads output file="$results_dir"/"$name"-results.csv diagnostic_file="$results_dir"/"$name"-diagnostic.csv random seed=$seed
fi    
