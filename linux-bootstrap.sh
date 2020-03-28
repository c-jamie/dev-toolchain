#!/usr/bin/env bash

CODE_DIR=$HOME/code
ARROW_DIR=$CODE_DIR/arrow
MINICONDA_DIR=$HOME/miniconda
TOOLCHAIN_DIR=$CODE_DIR/dev-toolchain

function build_user() {
	adduser droairne
	usermod -aG sudo droairne
    su - droairne

}

# Dotfiles
function install_dotfiles() {
    ln -sf $TOOLCHAIN_DIR/dotfiles/bash_personal ~/.bash_personal

	BASHRC_ADDITION=$(cat <<-END
	if [ -f ~/.bash_personal ]; then
	    . ~/.bash_personal
	fi
	END
	)
    echo "$BASHRC_ADDITION" >> ~/.bashrc
}

# packages
function install_apt_packages() {
    sudo apt install -y \
	    git \
        filezilla \
	    tmux \
        nodejs \
        yarn
}

# Miniconda
function install_conda() {
    MINICONDA_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    wget -O miniconda.sh $MINICONDA_URL
    bash miniconda.sh -b -p $MINICONDA_DIR
    rm -f miniconda.sh
    export PATH="$MINICONDA_DIR/bin:$PATH"

    conda update -y -q conda
    conda config --set auto_update_conda false
    conda info -a

    conda config --set show_channel_urls True
    conda config --add channels https://repo.continuum.io/pkgs/free
    conda config --add channels conda-forge

    conda init --all --verbose
}

# Install conda environments
function create_conda_dev_environments() {
    conda create -yq -n a37 \
          python=3.7 compilers clangxx
    conda create -yq -n p37 \
          python=3.7 pandas numpy ipython
}

# C++ toolchain
function install_cpp_toolchain() {
    conda install -y \
	  --file=$ARROW_DIR/ci/conda_env_cpp.yml \
	  --file=$ARROW_DIR/ci/conda_env_python.yml \
      -n a37 -c conda-forge

}

# arrow setup
function install_arrow() {
    mkdir -p $CODE_DIR
    pushd $CODE_DIR
    git clone https://github.com/apache/arrow.git
    git clone https://github.com/cill-airne/saighead-dev.git
    popd
}

# vim setup
function install_vim() {
    mkdir -p ~/.vim/plugged
    ln -sf $TOOLCHAIN_DIR/dotfiles/vimrc  ~/.vimrc
     ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

}

function setup_tmux() {
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ln -sf $TOOLCHAIN_DIR/dotfiles/tmux.conf  ~/.tmux.conf
}

install_dotfiles
install_apt_packages
install_conda
create_conda_dev_environments
install_arrow
install_cpp_toolchain
install_vim
setup_tmux
exec bash
