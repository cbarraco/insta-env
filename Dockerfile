FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive

# enable all apt repos
RUN sed -i -- 's/# deb/deb/g' /etc/apt/sources.list && apt-get update

# do basic config
RUN apt-get install -y sudo apt-utils locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# set up user
RUN useradd user && usermod -a -G sudo user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /home/user && chown user:user /home/user
ENV GOPATH=/home/user/.gocode
ENV PATH=$PATH:$GOPATH/bin

# install package managers
RUN apt-get install -y snapd golang nodejs

# install basic apps
RUN apt-get install -y git neovim bash-completion wget curl htop stow

USER user

# install lf
RUN go get -u github.com/gokcehan/lf

# get dotfiles
WORKDIR /home/user
RUN git clone https://github.com/cbarraco/dotfiles.git && \
    chmod +x ./dotfiles/install.sh && (cd dotfiles && ./install.sh)

# set up neovim
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' && \
    nvim --headless +PlugInstall +qall -
