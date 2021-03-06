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
        filezilla \
	    tmux \
        clang-format
}

function install_docker() {
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
       
    sudo apt-get install docker-ce docker-ce-cli containerd.io
}

function install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" \ 
    -o /usr/local/bin/docker-compose

    sudo chmod +x /usr/local/bin/docker-compose

    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
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
          python=3.7 pandas numpy ipython nb_conda_kernels
    conda create -yq -n jup \
          python=3.7 jupyterlab nb_conda_kernels
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

function install_git_scripts () {
    mkdir -p ~/sc
    ln -sf $TOOLCHAIN_DIR/scripts/rb_um.sh  ~/sc/rb_um.sh
    ln -sf $TOOLCHAIN_DIR/scripts/rst_um.sh  ~/sc/rst_um.sh
    ln -sf $TOOLCHAIN_DIR/scripts/build_arrow.sh  ~/sc/ba.sh
    ln -sf $TOOLCHAIN_DIR/scripts/build_pa.sh  ~/sc/bpa.sh

    git config --global user.name "c-jamie"
    git config --global user.email "jamie.b.clery@gmail.com"
}

# install_dotfiles
# install_apt_packages
# install_conda
# create_conda_dev_environments
# install_arrow
# install_cpp_toolchain
# install_vim
# setup_tmux
# install_docker
install_git_scripts
exec bash
