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
execPrefix=""
# GIT install

# depends pkgs for Ubuntu
ubuntuMissPkgs=(
    "libcurl4-openssl-dev"
    # "libssl-dev"     # will be installed along with libcurl4-openssl-dev
    "automake"
    "asciidoc"
    "xmlto"
    "libperl-dev"
)
# depends pkgs for CentOS
centOSMissPkgs=(
    "libcurl-devel"
    "automake"
    "asciidoc"
    "xmlto"
    "perl-devel"
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

installLibCurl() {
    cat << "_EOF"
    
------------------------------------------------------
STEP 1: INSTALLING LIBCURL ...
------------------------------------------------------
_EOF
    # libcurl  libcurl - Library to transfer files with ftp, http, etc.
    # -I/users/vbird/.usr/include
    whereIsLibcurl=`pkg-config --cflags libcurl`
    if [[ "$whereIsLibcurl" != "" ]]; then
        tmpPath=${whereIsLibcurl%%include*}    # -I/users/vbird/.usr
        curlPath=${tmpPath#*I}                 # /users/vbird/.usr
        echo [Warning]: system already has libcurl installed, omitting it ...
        return
    fi

    libcurlInstDir=$commInstdir
    wgetLink=https://curl.haxx.se/download
    tarName=curl-7.57.0.tar.gz
    untarName=curl-7.57.0

    # rename download package
    cd $startDir
    # check if already has this tar ball.
    if [[ -f $tarName ]]; then
        echo [Warning]: Tar Ball $tarName already exists, Omitting wget ...
    else
        wget --no-cookies \
            --no-check-certificate \
            --header "Cookie: oraclelicense=accept-securebackup-cookie" \
            "${wgetLink}/${tarName}" \
            -O $tarName
        # check if wget returns successfully
        if [[ $? != 0 ]]; then
            echo [Error]: wget returns error, quiting now ...
            exit
        fi
    fi

    tar -zxv -f $tarName
    cd $untarName
    ./configure --prefix=$libcurlInstDir
    make -j

    # check if make returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: make returns error, quiting now ...
        exit
    fi

    $execPrefix make install

    cat << _EOF
------------------------------------------------------
INSTALLING LIBCURL DONE ...
------------------------------------------------------
_EOF
}

installExpat() {
    cat << "_EOF"
    
------------------------------------------------------
STEP 2: INSTALLING EXPAT ...
------------------------------------------------------
_EOF
    # expat                       expat - expat XML parser
    # -I/users/vbird/.usr/include
    whereIsExpat=`pkg-config --cflags expat`
    if [[ "$whereIsExpat" != "" ]]; then
        tmpPath=${whereIsExpat%%include*}       # -I/users/vbird/.usr
        expatPath=${tmpPath#*I}                 # /users/vbird/.usr
        echo [Warning]: system already has libcurl installed, omitting it ...
        return
    fi

    expatInstDir=$commInstdir
    wgetLink=https://nchc.dl.sourceforge.net/project/expat/expat/2.2.5
    tarName=expat-2.2.5.tar.bz2
    untarName=expat-2.2.5

    # rename download package
    cd $startDir
    # check if already has this tar ball.
    if [[ -f $tarName ]]; then
        echo [Warning]: Tar Ball $tarName already exists, Omitting wget ...
    else
        wget --no-cookies \
            --no-check-certificate \
            --header "Cookie: oraclelicense=accept-securebackup-cookie" \
            "${wgetLink}/${tarName}" \
            -O $tarName
        # check if wget returns successfully
        if [[ $? != 0 ]]; then
            echo [Error]: wget returns error, quiting now ...
            exit
        fi
    fi

    tar -jxv -f $tarName
    cd $untarName
    ./configure --prefix=$expatInstDir
    make -j

    # check if make returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: make returns error, quiting now ...
        exit
    fi

    $execPrefix make install

    cat << _EOF
------------------------------------------------------
INSTALLING LIBCURL DONE ...
------------------------------------------------------
_EOF
}

installAsciidoc() {
    cat << "_EOF"
    
------------------------------------------------------
STEP : INSTALLING ASCIIDOC ...
------------------------------------------------------
_EOF
    if [[ "`which asciidoc 2> /dev/null`" != "" ]]; then
        echo [Warning] Already has asciidoc installed, omitting this step ...
        return
    fi
    asciidocInstDir=$commInstdir
    $execPrefix mkdir -p $commInstdir
    # comm attribute to get source 'git'
    gitClonePath=https://github.com/asciidoc/asciidoc
    clonedName=asciidoc
    checkoutVersion=8.6.10

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
    # checkout 
    git checkout $checkoutVersion
    # run make routine
    autoconf
    ./configure --prefix=$asciidocInstDir
    make -j
    # check if make returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: make returns error, quiting now ...
        exit
    fi
    make install
    cd $startDir

    cat << _EOF
    
------------------------------------------------------
INSTALLING ASCIIDOC DONE ...
`$asciidocInstDir/bin/asciidoc --version`
asciidoc path = $asciidocInstDir/bin/
------------------------------------------------------
_EOF
}

installXmlto() {
    cat << "_EOF"
    
------------------------------------------------------
STEP : INSTALLING XMLTO ...
------------------------------------------------------
_EOF
    if [[ "`which xmlto 2> /dev/null`" != "" ]]; then
        echo [Warning]: Already has xmlto installed, omitting this step ...
        return
    fi

    xmltoInstDir=$commInstdir
    wgetLink=https://releases.pagure.org/xmlto
    tarName=xmlto-0.0.21.tar.bz2
    untarName=xmlto-0.0.21

    # rename download package
    cd $startDir
    # check if already has this tar ball.
    if [[ -f $tarName ]]; then
        echo [Warning]: Tar Ball $tarName already exists, Omitting wget ...
    else
        wget --no-cookies \
            --no-check-certificate \
            --header "Cookie: oraclelicense=accept-securebackup-cookie" \
            "${wgetLink}/${tarName}" \
            -O $tarName
        # check if wget returns successfully
        if [[ $? != 0 ]]; then
            echo [Error]: wget returns error, quiting now ...
            exit
        fi
    fi

    tar -jxv -f $tarName
    cd $untarName
    ./configure --prefix=$xmltoInstDir
    make check
    # check if make returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: make returns error, quiting now ...
        exit
    fi

    make -j
    $execPrefix make install

    cat << _EOF
------------------------------------------------------
INSTALLING XMLTO DONE ...
`$xmltoInstDir/bin/xmlto --version`
xmlto path = $xmltoInstDir/bin/
------------------------------------------------------
_EOF
}

# fix dependency for root mode
fixDepends() {
    cat << "_EOF"
    
------------------------------------------------------
FIX DEPENDENCY ...
------------------------------------------------------
_EOF
    osType=`sed -n '1p' /etc/issue | tr -s " " | cut -d " " -f 1 | \
        grep -i "[ubuntu|centos]"`
    # fix dependency all together.
    case "$osType" in
        'Ubuntu')
            echo "OS is Ubuntu..."
            for pkg in ${ubuntuMissPkgs[@]}
            do
                sudo apt-get install $pkg -y
            done
        ;;

        'CentOS' | 'Red')
            echo "OS is CentOS or Red Hat..."
            for pkg in ${centOSMissPkgs[@]}
            do
                sudo yum install $pkg -y
            done
        ;;

        *)
            echo Not Ubuntu or CentOS
            echo not sure whether this script would work
            echo Please check it yourself ...
            exit
        ;;
    esac
    cat << "_EOF"
    
------------------------------------------------------
FIX DEPENDENCY DONE ...
------------------------------------------------------
_EOF
}

installGit() {
    cat << "_EOF"
    
------------------------------------------------------
STEP LAST: INSTALLING GIT ...
------------------------------------------------------
_EOF
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
    if [[ "$execPrefix" == "sudo" ]]; then
        ./configure --prefix=$gitInstDir
    else
        ./configure --prefix=$gitInstDir --with-curl=$curlPath \
            --with-expat=$expatPath
    fi

    make all doc -j
    # check if make returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: make returns error, quiting now ...
        exit
    fi

    $execPrefix make install install-doc install-html
    # fix small issue after install git
    if [[ "$execPrefix" == "sudo" ]]; then
        whoAmI=`whoami`
        tackleDir=~/.usr
        sudo chown -R $whoAmI:$whoAmI $tackleDir
    fi

    cat << "_EOF"
------------------------------------------------------
Installing Git Completion Bash To Home ...
------------------------------------------------------
_EOF
    gitCompletionBashPath=~/.git-completion.bash
    cp -f contrib/completion/git-completion.bash $gitCompletionBashPath
    source $gitCompletionBashPath
    cd $startDir

    cat << _EOF
    
------------------------------------------------------
INSTALLING GIT DONE ...
`$gitInstDir/bin/git --version`
git path = $gitInstDir/bin/
------------------------------------------------------
_EOF
}

install() {
    installLibCurl
    installExpat
    installGit
}

case $1 in
    'home')
        commInstdir=$homeInstDir
        execPrefix=""
        installLibCurl
        installExpat
        installAsciidoc
        installXmlto
        installGit
    ;;

    'root')
        commInstdir=$rootInstDir
        execPrefix=sudo
        fixDepends
        installGit
    ;;

    *)
        set +x
        usage
    ;;
esac
