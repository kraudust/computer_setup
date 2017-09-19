function install_vim {
    sudo apt-get install -y vim
}

function install_ros_kinetic {
    # let computer accept software from packages.ros.org
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

    # set up keys
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

    # make sure packages are updated
    sudo apt-get update

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
}

function install_graphic_card_drivers {
    sudo ubuntu-drivers autoinstall
}

function install_terminator {
    sudo apt-get install -y terminator
}

function setup_python {
    #install python packages
    sudo apt-get install -y python-numpy python-rospy python-scipy python-matplotlib python-genpy
    #install ipython
    sudo apt-get install -y ipython

    #source ros/kinetic to install roslib
    source /opt/ros/kinetic/setup.bash
    sudo apt-get install -y python-roslib
}

function install_nlopt {
    sudo apt-get install -y libnlopt-dev python-nlopt
}

function install_chrome {
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	  sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
	  sudo apt-get install -y -f
}

function install_atom {
    wget https://github.com/atom/atom/releases/download/v1.18.0/atom-amd64.deb
    sudo dpkg -i atom-amd64.deb
    sudo apt-get install -y -f
}


function setupMachine {
    #install_vim
    #wait
    install_ros_kinetic full
    wait
    install_terminator
    wait
    install_graphic_card_drivers
    wait
    setup_python
    wait
    install_nlopt
    wait
    install_chrome
    wait
    install_atom
    wait
    read -p "Setup complete.  It is necessary to reboot the computer. Press enter to proceed..."
    sudo reboot
}
