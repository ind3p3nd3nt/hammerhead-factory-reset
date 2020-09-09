#!/data/data/com.termux/files/usr/bin/bash -e

VERSION=2020030908
BASE_URL=https://build.nethunter.com/kalifs/kalifs-latest/
USERNAME=n3thunt3r

function unsupported_arch() {
    printf "${red}"
    echo "[*] Unsupported Architecture\n\n"
    printf "${reset}"
    exit
}

function ask() {
    # http://djm.me/ask
    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question
        printf "${light_cyan}\n[?] "
        read -p "$1 [$prompt] " REPLY

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        printf "${reset}"

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

function get_arch() {
    printf "${blue}[*] Checking device architecture ..."
    case $(getprop ro.product.cpu.abi) in
        arm64-v8a)
            SYS_ARCH=arm64
            ;;
        armeabi|armeabi-v7a)
            SYS_ARCH=armhf
            ;;
        *)
            unsupported_arch
            ;;
    esac
}

function set_strings() {
    CHROOT=kali-${SYS_ARCH}
    IMAGE_NAME=kalifs-${SYS_ARCH}-minimal.tar.xz
    SHA_NAME=kalifs-${SYS_ARCH}-minimal.sha512sum
}    

function prepare_fs() {
    unset KEEP_CHROOT
    if [ -d ${CHROOT} ]; then
        if ask "Existing rootfs directory found. Delete and create a new one?" "N"; then
            rm -rf ${CHROOT}
        else
            KEEP_CHROOT=1
        fi
    fi
} 

function cleanup() {
    if [ -f ${IMAGE_NAME} ]; then
        if ask "Delete downloaded rootfs file?" "N"; then
        if [ -f ${IMAGE_NAME} ]; then
                rm -f ${IMAGE_NAME}
        fi
        if [ -f ${SHA_NAME} ]; then
                rm -f ${SHA_NAME}
        fi
        fi
    fi
} 

function check_dependencies() {
    printf "${blue}\n[*] Checking package dependencies...${reset}\n"
    apt update -y &> /dev/null

    for i in proot tar axel; do
        if [ -e $PREFIX/bin/$i ]; then
            echo "  $i is OK"
        else
            printf "Installing ${i}...\n"
            apt install -y $i || {
                printf "${red}ERROR: Failed to install packages.\n Exiting.\n${reset}"
            exit
            }
        fi
    done
    apt upgrade -y
}


function get_url() {
    ROOTFS_URL="${BASE_URL}/${IMAGE_NAME}"
    SHA_URL="${BASE_URL}/${SHA_NAME}"
}

function get_rootfs() {
    unset KEEP_IMAGE
    if [ -f ${IMAGE_NAME} ]; then
        if ask "Existing image file found. Delete and download a new one?" "N"; then
            rm -f ${IMAGE_NAME}
        else
            printf "${yellow}[!] Using existing rootfs archive${reset}\n"
            KEEP_IMAGE=1
            return
        fi
    fi
    printf "${blue}[*] Downloading rootfs...${reset}\n\n"
    get_url
    axel ${EXTRA_ARGS} --alternate "$ROOTFS_URL"
}

function get_sha() {
    if [ -z $KEEP_IMAGE ]; then
        printf "\n${blue}[*] Getting SHA ... ${reset}\n\n"
        get_url
        if [ -f ${SHA_NAME} ]; then
            rm -f ${SHA_NAME}
        fi
        axel ${EXTRA_ARGS} --alternate "${SHA_URL}"
    fi
}

function verify_sha() {
    if [ -z $KEEP_IMAGE ]; then
        printf "\n${blue}[*] Verifying integrity of rootfs...${reset}\n\n"
        sha512sum -c $SHA_NAME || {
            printf "${red} Rootfs corrupted. Please run this installer again or download the file manually\n${reset}"
            exit 1
        }
    fi
}

function extract_rootfs() {
    if [ -z $KEEP_CHROOT ]; then
        printf "\n${blue}[*] Extracting rootfs... ${reset}\n\n"
        proot --link2symlink tar -xf $IMAGE_NAME 2> /dev/null || :
    else        
        printf "${yellow}[!] Using existing rootfs directory${reset}\n"
    fi
}

function update() {
    NH_UPDATE=${PREFIX}/bin/upd
    cat > $NH_UPDATE <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
unset LD_PRELOAD
user="root"
home="/root"
cmd1="/bin/apt update"
cmd2="/bin/apt-get install busybox sudo kali-tools. -y"
cmd3="/bin/apt full-upgrade -y"
cmd4="/bin/apt auto-remove -y"
nh -r \$cmd1;
nh -r \$cmd2;
nh -r \$cmd3;
nh -r \$cmd4;
EOF
    chmod +x $NH_UPDATE  
}

function webd() {
    NH_WEBD=${PREFIX}/bin/upd
    cat > $NH_WEBD <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
unset LD_PRELOAD
user="root"
home="/root"
cmd1="/bin/apt update"
cmd2="/bin/apt-get install apache2 net-tools sudo git -y"
cmd3="/bin/git clone https://github.com/independentcod/mollyweb"
cmd4="/bin/sh mollyweb/bootstrap.sh"
cmd5="/sbin/systemctl enable apache2"
cmd6="service apache2 start"
nh -r \$cmd1;
nh -r \$cmd2;
nh -r \$cmd3;
nh -r \$cmd4;
sed 's/Listen/#Listen/g' $CHROOT/etc/apache2/ports.conf;
echo Listen 8088 >> $CHROOT/etc/apache2/ports.conf;
echo Listen 8443 ssl >> $CHROOT/etc/apache2/ports.conf;
nh -r \$cmd5;
nh -r \$cmd6;
nh -r export myip=\$(ifconfig wlan0 | grep inet) && nh -r /bin/echo "Your apache2 IP address: http://\${myip}:8088 and https://\${myip}:8443";
EOF
    chmod +x $NH_WEBD  
}

function remote() {
    NH_REMOTE=${PREFIX}/bin/remote
    cat > $NH_REMOTE <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
cd \${HOME}
unset LD_PRELOAD
user="root"
home="/\$user"
nh -r /bin/apt update && nh -r /bin/apt install tigervnc-standalone-server lxde-core net-tools lxterminal -y;
user="n3thunt3r"
home="/home/\$user"
mkdir /home/\$user;
mkdir /home/\${user}/Desktop/;
if [ ! -d $CHROOT/\${home}/.vnc ]; then nh -r /bin/mkdir \${home}/.vnc; fi
echo 'lxsession &' > $CHROOT/\${home}/.vnc/xstartup;
echo 'lxterminal &' >> $CHROOT/\${home}/.vnc/xstartup;
if [ -f $CHROOT/tmp/.X3-lock ]; then rm -rf $CHROOT/tmp/.X3-lock && nh -r /bin/vncserver -kill :3; fi
nh -r /bin/vncserver :3 -localhost no;
nh -r echo 'VNC Server listening on 0.0.0.0:5903 you can remotely connect another device to that display with a vnc viewer';
nh -r export myip=\$(ifconfig wlan0 | grep inet) && nh -r echo "Your Phone IP address: \$myip";
EOF
    chmod +x $NH_REMOTE  
}



function create_launcher() {
    NH_LAUNCHER=${PREFIX}/bin/nethunter
    NH_SHORTCUT=${PREFIX}/bin/nh
    cat > $NH_LAUNCHER <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
cd \${HOME}
## termux-exec sets LD_PRELOAD so let's unset it before continuing
unset LD_PRELOAD
## Workaround for Libreoffice, also needs to bind a fake /proc/version
if [ ! -f $CHROOT/root/.version ]; then
    touch $CHROOT/root/.version
fi

## Default user is "n3thunt3r"
user="n3thunt3r"
home="/home/n3thunt3r"
start="sudo -u $USERNAME /bin/bash"

## NH can be launched as root with the "-r" cmd attribute
## Also check if user $USERNAME exists, if not start as root
if grep -q "$USERNAME" ${CHROOT}/etc/passwd; then
    KALIUSR="1";
else
    KALIUSR="0";
fi
if [[ \$KALIUSR == "0" || ("\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R")) ]]; then
    user="root"
    home="/\$user"

    start="/bin/bash --login"
    if [[ "\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R") ]]; then
        shift
    fi
fi

cmdline="proot \\
        --link2symlink \\
        -0 \\
        -r $CHROOT \\
        -b /dev \\
        -b /proc \\
        -b $CHROOT\$home:/dev/shm \\
        -w \$home \\
           /usr/bin/env -i \\
           HOME=\$home \\
           PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin \\
           TERM=\$TERM \\
           LANG=C.UTF-8 \\
           \$start"

cmd="\$@"
if [ "\$#" == "0" ]; then
    exec \$cmdline
else
    \$cmdline -c "\$cmd"
fi
EOF

    chmod 700 $NH_LAUNCHER
    if [ -L ${NH_SHORTCUT} ]; then
        rm -f ${NH_SHORTCUT}
    fi
    if [ ! -f ${NH_SHORTCUT} ]; then
        ln -s ${NH_LAUNCHER} ${NH_SHORTCUT} >/dev/null
    fi
   
}

function create_kex_launcher() {
    KEX_LAUNCHER=${CHROOT}/usr/bin/kex
    cat > $KEX_LAUNCHER <<- EOF
#!/bin/bash

function start-kex() {
    if [ ! -f /root/.vnc/passwd ]; then
        passwd-kex
    fi
    USR=\$(whoami)
    if [ \$USR == "root" ]; then
        SCREEN=":2"
    else
        SCREEN=":1"
    fi 
    export HOME=\${HOME}; export USER=\${USR}; LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgcc_s.so.1 nohup vncserver -localhost no \$SCREEN >/dev/null 2>&1 </dev/null
    starting_kex=1
    return 0
}

function stop-kex() {
    vncserver -kill :1 | sed s/"Xtigervnc"/"NetHunter KeX"/
    vncserver -kill :2 | sed s/"Xtigervnc"/"NetHunter KeX"/
    return $?
}

function passwd-kex() {
    vncpasswd
    return $?
}

function status-kex() {
    sessions=\$(vncserver -list | sed s/"TigerVNC"/"NetHunter KeX"/)
    if [[ \$sessions == *"590"* ]]; then
        printf "\n\${sessions}\n"
        printf "\nYou can use the KeX client to connect to any of these displays.\n\n"
    else
        if [ ! -z \$starting_kex ]; then
            printf '\nError starting the KeX server.\nPlease try "nethunter kex kill" or restart your termux session and try again.\n\n'
        fi
    fi
    return 0
}

function kill-kex() {
    pkill Xtigervnc
    return \$?
}

case \$1 in
    start)
        start-kex
        ;;
    stop)
        stop-kex
        ;;
    status)
        status-kex
        ;;
    passwd)
        passwd-kex
        ;;
    kill)
        kill-kex
        ;;
    *)
        stop-kex
        start-kex
        status-kex
        ;;
esac
EOF

    chmod 700 $KEX_LAUNCHER
}

function fix_profile_bash() {
    ## Prevent attempt to create links in read only filesystem
    if [ -f ${CHROOT}/root/.bash_profile ]; then
        sed -i '/if/,/fi/d' "${CHROOT}/root/.bash_profile"
    fi
}

function fix_sudo() {
    ## fix sudo & su on start
    if [ -f "$CHROOT/usr/bin/sudo" ]; then chmod +s $CHROOT/usr/bin/sudo; else nh -r /bin/apt update && nh -r /bin/apt install sudo busybox -y && chmod +s $CHROOT/usr/bin/sudo; fi
    if [ -f "$CHROOT/usr/bin/su" ]; then chmod +s $CHROOT/usr/bin/su; fi
    if [ ! -d "$CHROOT/etc/sudoers.d/" ]; then mkdir $CHROOT/etc/sudoers.d/; fi
    if [ ! -f "$CHROOT/etc/sudoers.d/$USERNAME" ]; then echo "$USERNAME    ALL=(ALL:ALL) NOPASSWD:ALL" > $CHROOT/etc/sudoers.d/$USERNAME; fi
    # https://bugzilla.redhat.com/show_bug.cgi?id=1773148
    echo "Set disable_coredump false" > $CHROOT/etc/sudo.conf
}

function fix_uid() {
    ## Change $USERNAME uid and gid to match that of the termux user
    USRID=$(id -u)
    GRPID=$(id -g)
    nh -r usermod -u $USRID $USERNAME 2>/dev/null
    nh -r groupmod -g $GRPID $USERNAME 2>/dev/null
}

function print_banner() {
    clear
    printf "${blue}##################################################\n"
    printf "${blue}##                                              ##\n"
    printf "${blue}##  88      a8P         db        88        88  ##\n"
    printf "${blue}##  88    .88'         d88b       88        88  ##\n"
    printf "${blue}##  88   88'          d8''8b      88        88  ##\n"
    printf "${blue}##  88 d88           d8'  '8b     88        88  ##\n"
    printf "${blue}##  8888'88.        d8YaaaaY8b    88        88  ##\n"
    printf "${blue}##  88P   Y8b      d8''''''''8b   88        88  ##\n"
    printf "${blue}##  88     '88.   d8'        '8b  88        88  ##\n"
    printf "${blue}##  88       Y8b d8'          '8b 888888888 88  ##\n"
    printf "${blue}##            Forked by @independentcod         ##\n"
    printf "${blue}################### NetHunter ####################${reset}\n\n"
}

##################################
##              Main            ##

# Add some colours
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;34m'
light_cyan='\033[1;96m'
reset='\033[0m'

EXTRA_ARGS=""
if [[ ! -z $1 ]]; then
    EXTRA_ARGS=$1
    if [[ $EXTRA_ARGS != "--insecure" ]]; then
        EXTRA_ARGS=""
    fi
fi

cd $HOME
print_banner
get_arch
set_strings
prepare_fs
check_dependencies
get_rootfs
get_sha
verify_sha
extract_rootfs
printf "\n${blue}[*] Configuring NetHunter for Termux ...\n"
create_launcher
update
remote
webd
nh -r /sbin/useradd $USERNAME
echo "127.0.0.1   OffensiveSecurity OffensiveSecurity.localdomain OffensiveSecurity OffensiveSecurity.localdomain4" > $CHROOT/etc/hosts
echo "::1         OffensiveSecurity OffensiveSecurity.localdomain OffensiveSecurity OffensiveSecurity.localdomain6" >> $CHROOT/etc/hosts
cleanup
fix_profile_bash
fix_sudo
create_kex_launcher
fix_uid
print_banner
printf "${green}[=] NetHunter for Termux installed successfully${reset}\n\n"
printf "${green}[+] To start NetHunter, type:${reset}\n"
printf "${green}[+] nethunter             # To start NetHunter cli${reset}\n"
printf "${green}[+] nethunter kex passwd  # To set the KeX password${reset}\n"
printf "${green}[+] nethunter kex &       # To start NetHunter gui${reset}\n"
printf "${green}[+] nethunter kex stop    # To stop NetHunter gui${reset}\n"
printf "${green}[+] nethunter -r          # To run NetHunter as root${reset}\n"
printf "${green}[+] nh                    # Shortcut for nethunter${reset}\n\n"
printf "${green}[+] upd                   # To update everything and install all kali-tools${reset}\n\n"
printf "${green}[+] remote                # To install a LXDE Display Manager on port 5903 reachable by other devices${reset}\n\n"
printf "${green}[+] webd                  # To install an SSL Website www.mollyeskam.net as template ${reset}\n\n"
