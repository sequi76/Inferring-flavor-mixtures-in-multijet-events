# Inferring-flavor-mixtures-in-multijet-events
Codes and datasets for paper Inferring flavor mixtures in multijet events (Y.Yao &amp; E.Alvarez)

Warning: take you time to read this readme file because otherwise it is very hard to understand what there is in this repo and how to use it

## 1- Big Picture

The files in this repo are in directories with a precise structure to be merged in a CMDSTAN running directory.  That is, when you download the latest CMDSTAN version from

https://github.com/stan-dev/cmdstan/releases/latest

and you unpack the tarball (and run make of course, see <a href='https://github.com/stan-dev/cmdstan'>instructions</a>), then you'll get a directory with a subdirectory <i>models/</i>.  Then, 'merging' this repo into that CMDSTAN installation means putting everything that is in this directory <i>models/</i> into the CMDSTAN directory with the same name.  But do not copy the directory, but its contents (otherwise you'll delete the CMDSTAN original content in that directory).

## 2- Each Directory content, purpose, and how to use it

### Directory: '/' (This directory)

You find in this directory some '.bash' files that when you run them it runs cmdstan with the specific choices (see below).  The current '.bash' files now are just for the sake of exemplify.  In a true situation, these files are created with some Python notebooks in 'models/notebooks' as you'll see below.

When you run these '.bash' files they create the output of the run in 'models/notebook/results/'.  This output is then analyzed with the corresponding notebooks in 'models/notebooks'.  Each run is tagged with a key in the form e.g. '03-03-2024.22.57UM', where obviously this means the creation date, and the 2 last letters indicate which model has been used

- dr = Dirichlet
- hs = Gaussian process
- um = Unimodal
- pe = Point Estimate


### Directory: '/models/'

Directory containing 4 directories with the stan scripts for each model and the .json files for each run of each model.

### Directory: 'models/gp'

Contains the running files for the model Gaussian process, for instance:

- 'gp1\_no-correlation\_parallel.stan':  Stan script that when compiled creates an executable with the same name (without the .stan at the end).  It is executed from the basg files in the home '/' directory
- '04-02-2024.23.59Dr.json': json file which is the dictionary needed to run the executable stan script.  It contains, for instance, the mean priors, and also the synthetic data sampled in the given instance of the run.  This file is created from the notebooks in '/models/notebooks'

### Directory: 'models/dirichlet'

idem as before, but for model Dirichlet

### Directory: 'models/unimode'

idem as before, but for model Unimode

### Directory: 'models/point-estimate'

idem as before, but for model Point Estimate

### Directory: '/models/notebooks'

This directory contains the Python notebooks from which everything is created

- '1D-cmdstan-bash-generator.ipynb'

This notebook creates the files '1D-gp.bash', '1D-dirichlet.bash', '1D-unimode.bash' and '1D-point-estimate.bash' present in this '/' directory. In the notebook you'll find the four corresponding functions and how to call them.  You must specify things like the number of data-points, the seed, the prior means, etc.  This bash files run the stan scripts to infer the posteriors in th 1-dimensional examples.


- '4D-cmdstan-bash-generator.ipynb'

This notebook is similar to the 1D, just that now samples the data in 4D, and creates the corresponding 4D bash files, namely: 'gp.bash', 'dirichlet.bash', 'unimode.bash', and 'point-estimate.bash'.  

You should read the functions that generate the data, the json files, the bash files, etc.  You need to understand themto understand how to use them properly.  In any case, at the end of the notebook there are a few examples on how to run each function.


