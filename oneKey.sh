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

        case "$osType" in
            'CentOS')
                echo OS is CentOS
                sudo yum install libcurl-devel
            ;;

            'Ubuntu')
                echo OS is Ubuntu
                sudo apt-get install libcurl4-openssl-dev
            ;;

            *)
                echo Not Ubuntu or CentOS, not sure whether this script would work
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
            commInstdir=/usr/local
            execPrefix=sudo
        ;;
    esac

    gitInstDir=$commInstdir
    gitClonePath=https://github.com/git/git
    clonedName=git
    checkoutVersion=v2.15.0
    $execPrefix mkdir -p $commInstdir

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

echo $1
case $1 in
    'home' | 'root')
        install $1
    ;;

    *)
        set +x
        usage
    ;;
esac
