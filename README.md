# rcloud.jupyter.notebooks
[![Build Status](https://travis-ci.org/att/rcloud.jupyter.notebooks.svg?branch=master)](https://travis-ci.org/att/rcloud.jupyter.notebooks)[![Coverage Status](https://img.shields.io/codecov/c/github/att/rcloud.jupyter.notebooks/develop.svg)](https://codecov.io/gh/att/rcloud.jupyter.notebooks?branch=develop)

RCloud is an environment for collaboratively creating and sharing data analysis scripts. RCloud lets you mix analysis code in R, HTML5, Markdown, Python, and others.

The rcloud.jupyter.notebooks package provides an extension to import and export Jupyter notebooks in RCloud.


## Install

1. Install this package on RCloud, using `devtools::install_github()`,
   or `install-github.me`:
   ```R
   source("https://github.com/MangoTheCat/rcloud.jupyter.notebooks")
   ```
2. In the RCloud *Settings* menu, in the *Enable Extensions* line, add
   `rcloud.jupyter.notebooks`, so that the package is loaded automatically.
3. Reload RCloud in the browser. This loads the package, and you should
   have the *Import as Jupyter Notebook* and *Export as Jupyter Notebook* items added
   int the *Advanced* menu on the top.

## Usage

### In RCloud

Choose the *Import as Jupyter Notebook* item from the *Advanced* menu and
then select the *.ipynb* file to import from your computer.

or

Choose the *Export as Jupyter Notebook* item from the *Advanced* menu and the current
RCloud notebook will be exported.
