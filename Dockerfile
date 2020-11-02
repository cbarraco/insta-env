FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive

# enable all apt repos
RUN sed -i -- 's/# deb/deb/g' /etc/apt/sources.list && \
    sed -i -- 's/http:\/\/archive.ubuntu.com\/ubuntu/http:\/\/ubuntu.mirror.rafal.ca\/ubuntu/g' /etc/apt/sources.list && \
    apt-get update

# do basic config
RUN apt-get install -y sudo apt-utils locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# set up user
RUN useradd user && usermod -a -G sudo user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /home/user && chown user:user /home/user

# install basic apps
RUN apt-get install -y git bash-completion wget curl jq stow

# set up neovim
RUN apt-get install -y neovim
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' && \
    nvim --headless +PlugInstall +qall -

# install miniconda3
ENV PATH /opt/conda/bin:$PATH
RUN apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# install go programs
ENV GOPATH=/home/user/.gocode
ENV PATH=$PATH:$GOPATH/bin
RUN apt-get install -y golang
RUN go get -u github.com/gokcehan/lf github.com/shenwei356/rush

# get dotfiles
USER user
WORKDIR /home/user
RUN git clone https://github.com/cbarraco/dotfiles.git .dotfiles && \
    chmod +x ./.dotfiles/install.sh && (cd .dotfiles && ./install.sh)
