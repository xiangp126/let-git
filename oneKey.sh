#!/bin/bash
set -x

# this shell start dir, normally original path
startDir=`pwd`
# main work directory, usually ~/myGit
mainWd=$startDir

# common install dir for home | root mode
homeInstDir=~/.usr
rootInstDir=/usr/local
# default is home mode
commInstdir=$homeInstDir
gitInstDir=$commInstdir

# depends pkgs for Ubuntu
ubuntuMissPkgs=(
    "libcurl4-openssl-dev"
    # "libssl-dev"     # will be installed along with libcurl4-openssl-dev
    "automake"
)
# depends pkgs for CentOS
centOSMissPkgs=(
    "libcurl-devel"
    "automake"
)

logo() {
    cat << "_EOF"
  ____ ___ _____
 / ___|_ _|_   _|
| |  _ | |  | |
| |_| || |  | |
 \____|___| |_|

_EOF
}

usage() {
    exeName=${0##*/}
    cat << _EOF
[NAME]
    $exeName -- setup Git through one script

[SYNOPSIS]
    $exeName [home | root | help]

[DESCRIPTION]
    home -- install to $homeInstDir/
    root -- install to $rootInstDir/

_EOF
	logo
}

installGit() {
    
    cat << "_EOF"
    
------------------------------------------------------
STEP 1: INSTALLING GIT ...
------------------------------------------------------
_EOF

    # libcurl  libcurl - Library to transfer files with ftp, http, etc.
    whereIsLibcurl=`pkg-config --list-all | grep -i curl`
    if [[ "$whereIsLibcurl" == "" ]]; then
        echo No libcurl-dev found, install it first 
        echo verifying platform is Ubuntu or Centos ...
        osType=`sed -n '1p' /etc/issue | tr -s " " | cut -d " " -f 1 | \
            grep -i "[ubuntu|centos]"`

        # fix dependency all together.
        case "$osType" in
            'CentOS')
                echo "OS is CentOS ..."
                for pkg in ${centOSMissPkgs[@]}
                do
                    sudo yum install $pkg -y
                done
            ;;

            'Ubuntu')
                echo "OS is Ubuntu..."
                for pkg in ${ubuntuMissPkgs[@]}
                do
                    sudo apt-get install $pkg -y
                done
            ;;

            *)
                echo Not Ubuntu or CentOS
                echo not sure whether this script would work
                echo Please check it yourself ...
                exit
            ;;
        esac
    fi

    execPrefix=""
    case $1 in
        'home')
        ;;

        'root')
            commInstdir=$rootInstDir
            execPrefix=sudo
        ;;
    esac

    gitInstDir=$commInstdir
    $execPrefix mkdir -p $commInstdir
    # comm attribute to get source 'git'
    gitClonePath=https://github.com/git/git
    clonedName=git
    checkoutVersion=v2.15.0

    # rename download package
    cd $startDir
    # check if already has this tar ball.
    if [[ -d $clonedName ]]; then
        echo [Warning]: target $clonedName/ already exists, Omitting now ...
    else
        git clone ${gitClonePath} $clonedName
        # check if git clone returns successfully
        if [[ $? != 0 ]]; then
            echo [Error]: git clone returns error, quiting now ...
            exit
        fi
    fi

    cd $clonedName
    # checkout to v2.15.0
    git checkout $checkoutVersion
    # run make routine
    make configure
    ./configure --prefix=$gitInstDir
    make -j 1

	# check if make returns successfully
	if [[ $? != 0 ]]; then
		echo [Error]: make returns error, quiting now ...
		exit
	fi

    $execPrefix make install

    cat << "_EOF"
------------------------------------------------------
Installing Git Completion Bash To Home ...
------------------------------------------------------
_EOF
    gitCompletionBashPath=~/.git-completion.bash
    cp -f contrib/completion/git-completion.bash $gitCompletionBashPath
    source $gitCompletionBashPath

    cat << _EOF
    
------------------------------------------------------
INSTALLING GIT DONE ...
`./git --version`
git path = $gitInstDir/bin/
------------------------------------------------------
_EOF
}

install() {
    installGit $1
}

case $1 in
    'home' | 'root')
        install $1
    ;;

    *)
        set +x
        usage
    ;;
esac
