# Inferring-flavor-mixtures-in-multijet-events
Codes and datasets for paper Inferring flavor mixtures in multijet events (Y.Yao &amp; E.Alvarez)

Warning: take your time to read this readme file because otherwise it is very hard to understand what there is in this repo and how to use it

## 1- Big Picture

The files in this repo are in directories with a precise structure to be merged in a CMDSTAN running directory.  That is, when you download the latest CMDSTAN version from

https://github.com/stan-dev/cmdstan/releases/latest

and you unpack the tarball (and run make of course, see <a href='https://github.com/stan-dev/cmdstan'>instructions</a>), then you'll get a directory with a subdirectory <i>models/</i>.  Then, 'merging' this repo into that CMDSTAN installation means putting everything that is in this directory <i>models/</i> into the CMDSTAN directory with the same name.  But do not copy the directory, but its contents (otherwise you'll delete the CMDSTAN original content in that directory).

[Observe, in any case, that if you want to use <b>pystan</b> (the Python version for Stan), then you should: i) Collect the .stan files from models/gp, models/dirichlet, models/unimode, models/point-estimate and use them direct;y in <b>pystan</b>; ii) Use the notebooks in models/notebooks to generate the synthetic data to feed the Stan models.  However you'll not be taking profit of all the power of the notebooks that are already organized to just generate data, run it and analyze it.  But we understand it if you really don't want to go to the command-line Stan version.]

## 2- Each Directory content, purpose, and how to use it

### 2a- Directory: '/' (This directory)

You find in this directory some '.bash' files that when you run them it runs cmdstan with the specific choices (see below).  The current '.bash' files now are just for the sake of exemplify.  In a true situation, these files are created with some Python notebooks in 'models/notebooks' as you'll see below.

When you run these '.bash' files they create the output of the run in 'models/notebook/results/'.  This output is then analyzed with the corresponding notebooks in 'models/notebooks'.  Each run is tagged with a key in the form e.g. '03-03-2024.22.57UM', where obviously this means the creation date, and the 2 last letters indicate which model has been used

- dr = Dirichlet
- hs = Gaussian process
- um = Unimodal
- pe = Point Estimate


### 2b- Directory: '/models/'

Directory containing 4 directories with the stan scripts for each model and the .json files for each run of each model.

### 2c- Directory: 'models/gp'

Contains the running files for the model Gaussian process, for instance:

- 'gp1\_no-correlation\_parallel.stan':  Stan script that when compiled creates an executable with the same name (without the .stan at the end).  It is executed from the basg files in the home '/' directory
- '04-02-2024.23.59Dr.json': json file which is the dictionary needed to run the executable stan script.  It contains, for instance, the mean priors, and also the synthetic data sampled in the given instance of the run.  This file is created from the notebooks in '/models/notebooks'

### 2d- Directory: 'models/dirichlet'

idem as before, but for model Dirichlet

### 2e- Directory: 'models/unimode'

idem as before, but for model Unimode

### 2f- Directory: 'models/point-estimate'

idem as before, but for model Point Estimate

### 2g- Directory: '/models/notebooks'

This directory contains the Python notebooks from which everything is created

- '1D-cmdstan-bash-generator.ipynb'

This notebook creates the files '1D-gp.bash', '1D-dirichlet.bash', '1D-unimode.bash' and '1D-point-estimate.bash' present in this '/' directory. In the notebook you'll find the four corresponding functions and how to call them.  You must specify things like the number of data-points, the seed, the prior means, etc.  This bash files run the stan scripts to infer the posteriors in th 1-dimensional examples.


- '4D-cmdstan-bash-generator.ipynb'

This notebook is similar to the 1D, just that now samples the data in 4D, and creates the corresponding 4D bash files, namely: 'gp.bash', 'dirichlet.bash', 'unimode.bash', and 'point-estimate.bash'.  

You should read the functions that generate the data, the json files, the bash files, etc.  You need to understand themto understand how to use them properly.  In any case, at the end of the notebook there are a few examples on how to run each function.

- 'full-process-results.ipynb'

Notebook to process all the runs of a given seed.  

As it is currently the notebook you need to have computed the N=100, 250 and 500 for the all four models, and also the 1D cases in order to get all the figures that are in the paper.  Obviously that if you start to play with this you sohuld take apart some of the defined functions and copmute your priors, or some outputs, or fractions, or distributions, and see how they look like.


### 2e- Directory '/models/notebooks/results'

All the results that come from the .bash runs end up in this directory.  That is, all the samples from the posterior in each inference case.

## 3- Sone notes to take into account

- In this repo there are a few results .csv, .bash and .json files just fo the sake of exmeplifying.  We couldn't load all of the run in the paper because of size limit.
- All this has been run in Ubuntu 20 LTS
- Before running anything, when you run make to compile cmdstan, you need to compile with the 

\# Enable threading <br>
 STAN\_THREADS=true

option in the '/make/local' configuration file

- To copmile the .stan files you need to compile then from the home directory using, for instance, this command

make models/unimode/1D-unimode2\_symmetric\_Dirichtlet

## 4- Last wishes

Good luck and write to sequi@unsam.edu.ar if you need any assistance!

