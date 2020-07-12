export ARROW_HOME=~/code/arrow/cpp/build/dist
export LD_LIBRARY_PATH=$(pwd)/dist/lib:$LD_LIBRARY_PATH

export CONDA_HOME=~/miniconda
eval "$($CONDA_HOME/bin/conda shell.bash hook)"

conda activate a37

pushd ~/code/arrow/python
python setup.py build_ext --inplace