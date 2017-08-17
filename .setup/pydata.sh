#!/usr/bin/env bash

# Removed user's cached credentials
# This script might be run with .dots, which uses elevated privileges
sudo -K

echo "------------------------------"
echo "Setting up pip."

# Install pip
easy_install pip

###############################################################################
# Virtual Enviroments                                                         #
###############################################################################

echo "------------------------------"
echo "Setting up virtual environments."

# Install virtual environments globally
# It fails to install virtualenv if PIP_REQUIRE_VIRTUALENV was true
export PIP_REQUIRE_VIRTUALENV=false
pip install virtualenv
pip install virtualenvwrapper

echo "------------------------------"
echo "Source virtualenvwrapper from ~/.extra"

EXTRA_PATH=~/.extra
echo $EXTRA_PATH
echo "" >> $EXTRA_PATH
echo "" >> $EXTRA_PATH
echo "# Source virtualenvwrapper, added by python.sh" >> $EXTRA_PATH
echo "export WORKON_HOME=~/.virtualenvs" >> $EXTRA_PATH
echo "source /usr/local/bin/virtualenvwrapper.sh" >> $EXTRA_PATH
echo "" >> $BASH_PROFILE_PATH
source $EXTRA_PATH

###############################################################################
# Python 2 Virtual Enviroment                                                 #
###############################################################################

echo "------------------------------"
echo "Setting up py2 virtual environment."

# Create a Python2 data environment
mkvirtualenv py2
workon py2

# Install Python data modules
pip install numpy
pip install scipy
pip install matplotlib
pip install pandas
pip install sympy
pip install nose
pip install unittest2
pip install seaborn
pip install scikit-learn
pip install "ipython[all]"
pip install bokeh
pip install Flask
pip install sqlalchemy
pip install mysql-python

###############################################################################
# Python 3 Virtual Enviroment                                                 #
###############################################################################

echo "------------------------------"
echo "Setting up py3 virtual environment."

# Create a Python3 data environment
mkvirtualenv --python=/usr/local/bin/python3 py3
workon py3

# Install Python data modules
pip install numpy
pip install scipy
pip install matplotlib
pip install pandas
pip install sympy
pip install nose
pip install unittest2
pip install seaborn
pip install scikit-learn
pip install "ipython[all]"
pip install bokeh
pip install Flask
pip install sqlalchemy
#pip install mysql-python  # Python 2 only, use mysqlclient instead
pip install mysqlclient

###############################################################################
# Install IPython Profile
###############################################################################

echo "------------------------------"
echo "Installing IPython Notebook Default Profile"

# Add the IPython profile
mkdir -p ~/.ipython
cp -r .init/profile_default/ ~/.ipython/profile_default

###############################################################################
# Install Jupyter Profile
###############################################################################

echo "------------------------------"
echo "Installing Jupyter Notebook Default Profile"

pip3 install jupyter
pip3 install jupyter_contrib_nbextensions

echo "------------------------------"
echo "Script completed."
echo "Usage: workon py2 for Python2"
echo "Usage: workon py3 for Python3"
# Create required directory in case (optional)
mkdir -p /Users/v/Library/Jupyter/nbextensions
# Clone the repository
cd /Users/v/Library/Jupyter/nbextensions
git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding
# Activate the extension
jupyter nbextension enable vim_binding/vim_binding
curl -O https://repo.continuum.io/archive/Anaconda3-4.4.0-MacOSX-x86_64.sh
#Run the above in bash; TODO: Clean this file up.
