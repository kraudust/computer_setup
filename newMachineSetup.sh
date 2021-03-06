function install_vim {
    sudo apt-get update
    sudo apt-get install -y vim
    # install Vundle if it isn't installed
    if [ ! -e ~/computer_setup/.vim/bundle/Vundle.vim ]; then
        echo "Installing Vundle"
        cd ~/computer_setup
        git clone https://github.com/VundleVim/Vundle.vim.git ~/computer_setup/.vim/bundle/Vundle.vim
    fi
    git config --global core.editor vim
    git config --global push.default simple
    echo "VIM configured"
}

function install_ros_kinetic {
    # let computer accept software from packages.ros.org
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

    # set up keys
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

    # make sure packages are updated
    # sudo apt-get update

    #depending on the input argument, do the correct install
    if [ $1 == "full" ];
    then
        # do full install
        sudo apt-get install -y ros-kinetic-desktop-full;
    fi
    if [ $1 == "desktop" ];
    then
        # do full install
        sudo apt-get install -y ros-kinetic-desktop;
    fi
    if [ $1 == "barebones" ];
    then
        # do full install
        sudo apt-get install -y ros-kinetic-ros-base;
    fi

    # initialize rosdep
    sudo rosdep init
    rosdep update

    # install dependencies for building packages
    sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

    # get additional package for gazebo
    sudo apt-get install -y ros-kinetic-gazebo-ros-control
    echo "ROS Installed"
}

function install_graphic_card_drivers {
    sudo ubuntu-drivers autoinstall
}

function install_terminator {
    sudo apt-get install -y terminator
    echo "Terminator Installed"
}

function setup_python_etc {
    #install python packages
    sudo apt-get install -y python-numpy python-rospy python-scipy python-matplotlib python-genpy python-pip python-dev build-essential vlc ssh gimp
    #install ipython
    sudo apt-get install -y ipython

    #source ros/kinetic to install roslib
    source /opt/ros/kinetic/setup.bash
    sudo apt-get install -y python-roslib
    echo "Python Configured"
}

function install_nlopt {
    sudo apt-get install -y libnlopt-dev python-nlopt
    echo "NLOPT Installed"
}

function install_chrome {
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	  sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
	  sudo apt-get install -y -f
      echo "Chrome Installed"
}

function install_atom {
    wget https://github.com/atom/atom/releases/download/v1.18.0/atom-amd64.deb
    sudo dpkg -i atom-amd64.deb
    sudo apt-get install -y -f
    echo "Atom installed"
}

function configure_dot_files {
	dir=~/computer_setup # directory containing dot files (name of git repo w/ them)
	olddir=~/dotfiles_old # move current dot files on machine to this directory
	files=".bashrc .vimrc .vim" # list of files/folders to symlink in home directory
	if [ ! -e $olddir ]; then
		echo "Creating $olddir for backup of any existing dotfiles in ~"
		mkdir -p $olddir
		echo "...done"
	fi
	echo "Changing to the $dir directory"
	cd $dir
	echo "...done"
	for file in $files; do
		echo "Moving any existing dotfiles from ~ to $olddir"
		mv ~/$file $olddir/
		echo "Creating symlink to $file in home directory."
		ln -s $dir/$file ~/$file
	done
	source ~/.bashrc
    echo "Dot files configured"
}

function configure_git_repos {
    # install git
    sudo apt-get update
    sudo apt-get install -y git
    # clone byu classes repository
    git clone https://github.com/kraudust/byu_classes.git ~/git/personal_git/byu_classes
    cd ~/git/personal_git/byu_classes
    git config --global user.name "Dustan Kraus"
    git config --global user.email "dustan.kraus@gmail.com"
    git config --global credential.https://github.com.username kraudust
    # clone byu repositories
    git clone https://kraudust@bitbucket.org/byu_rad_lab/cur_devel.git ~/git/byu/cur_devel
    cd ~/git/byu/cur_devel
    git config --global user.name "Dustan Kraus"
    git config --global user.email "dustan.kraus@byu.edu"
    echo "Git repos cloned"
}

function install_trac_ik {
    sudo apt-get install -y ros-kinetic-trac-ik
    echo "Trac IK installed"
}

function install_swig {
    sudo apt-get install -y swig3.0
    echo "Swig Installed"
}

function install_boost {
    sudo apt-get install -y libboost-all-dev
    echo "boost installed"
}

function install_sympybotics {
    sudo apt-get install -y python-setuptools

    cd ~/git
    git clone git://github.com/sympy/sympy.git
    cd sympy
    sudo python setup.py install

    cd ~/git
    mkdir cdsousa
    cd cdsousa

    #must have .ssh key generated, find way to automatically check this
    git clone https://github.com/cdsousa/SymPyBotics.git
    cd SymPyBotics
    sudo python setup.py install
    echo "Sympybotics installed"
}

function install_latex {
    # sudo add-apt-repository ppa:jonathonf/texlive-2016
    # sudo apt update
    sudo apt-get install -y texlive-full
    sudo apt-get install -y texmaker
    echo "LATEX installed"
}

function install_mendeley {
    wget -c www.mendeley.com/repositories/ubuntu/stable/amd64/mendeleydesktop-latest
    sudo dpkg -i mendeleydesktop-latest
    sudo apt-get install -y -f
    echo "Mendeley Installed"
}

function install_spotify {
    # 1. Add the Spotify repository signing keys to be able to verify downloaded packages
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410

    # 2. Add the Spotify repository
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

    # 3. Update list of available packages
    sudo apt-get update

    # 4. Install Spotify
    sudo apt-get install -y spotify-client 
    echo "Spotify Installed"
}

function setupMachine {
    # configure_git_repos
    # wait
    install_vim
    wait
    configure_dot_files
    wait
    install_ros_kinetic full
    wait
    install_terminator
    wait
    # install_graphic_card_drivers
    # wait
    setup_python_etc
    wait
    install_nlopt
    wait
    install_chrome
    wait
    install_trac_ik
    wait
    install_swig
    wait
    install_boost
    wait
    install_sympybotics
    wait
    install_latex
    wait
    install_mendeley
    wait
    install_spotify
    wait
    # install_atom
    # wait
    read -p "Setup complete.  It is necessary to reboot the computer. Press enter to proceed..."
    sudo reboot
}
