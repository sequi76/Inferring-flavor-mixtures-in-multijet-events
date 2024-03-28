# Inferring-flavor-mixtures-in-multijet-events
Codes and datasets for paper Inferring flavor mixtures in multijet events (Y.Yao &amp; E.Alvarez)

Warning: take you time to read this readme file because otherwise it is very hard to understand what there is in this repo and how to use it

## Big Picture

The files in this repo are in directories with a precise structure to be merged in a CMDSTAN running directory.  That is, when you download the latest CMDSTAN version from

https://github.com/stan-dev/cmdstan/releases/latest

and youunpack the tarball (and run make of course, see <a href='https://github.com/stan-dev/cmdstan'>instructions</a>), then you'll get a directory with a subdirectory <i>models/</i>.  Then, 'merging' this repo into that CMDSTAN installation means putting everything that is in this directory <i>models/</i> into the CMDSTAN directory with the same name.  But do not copy the directory, but its contents (otherwise you'll delete the CMDSTAN original content in that directory).
