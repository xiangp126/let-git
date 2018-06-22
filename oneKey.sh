#!/bin/bash
startDir=`pwd`
# main work directory, not influenced by start dir
mainWd=$(cd $(dirname $0); pwd)
# GIT install
# common install dir for home | root mode
homeInstDir=~/.usr
rootInstDir=/usr/local
# default is home mode
commInstdir=$homeInstDir
#sudo or empty
execPrefix=""
downloadPath=$mainWd/downloads
cpuCoreNum=""

logo() {
    cat << "_EOF"
 _      _            _ _
| | ___| |_     __ _(_) |_
| |/ _ \ __|__ / _` | | __|
| |  __/ ||___| (_| | | |_
|_|\___|\__|   \__, |_|\__|
               |___/

_EOF
}

usage() {
    exeName=${0##*/}
    cat << _EOF
[NAME]
    $exeName -- install Git latest release through one script

[SYNOPSIS]
    sh $exeName [home | root | help]

[DESCRIPTION]
    home -- install to $homeInstDir/
    root -- install to $rootInstDir/

_EOF
    logo
}

checkCpuCoreNum() {
    if [[ "`which lscpu 2> /dev/null`" == "" ]]; then
        # echo [Warning]: OS has no lscpu installed, omitting this
        # macos did not has lscpu, so remomve [job] restrict
        cpuCoreNum=""
        return
    fi
    # set new os cpus
    cpuCoreNum=`lscpu | grep -i "^CPU(s):" | tr -s " " | cut -d " " -f 2`
    if [[ "$cpuCoreNum" == "" ]]; then
        cpuCoreNum=1
    fi
    # echo "OS has CPU(S): $cpuCoreNum"
}

installLibCurl() {
    cat << "_EOF"
------------------------------------------------------
INSTALLING LIBCURL ...
------------------------------------------------------
_EOF
    # libcurl  libcurl - Library to transfer files with ftp, http, etc.
    # -I/users/vbird/.usr/include
    whereIsLibcurl=`pkg-config --libs libcurl 2> /dev/null`
    if [[ "$whereIsLibcurl" != "" ]]; then
        # tmpPath=${whereIsLibcurl%%include*}    # -I/users/vbird/.usr
        # curlPath=${tmpPath#*I}                 # /users/vbird/.usr
        echo [Warning]: system already has libcurl installed, omitting it ...
        return
    fi

    libcurlInstDir=$commInstdir
    wgetLink=https://curl.haxx.se/download
    tarName=curl-7.57.0.tar.gz
    untarName=curl-7.57.0

    # rename download package
    cd $downloadPath
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
}

installExpat() {
    cat << "_EOF"
------------------------------------------------------
INSTALLING EXPAT ...
------------------------------------------------------
_EOF
    # expat                       expat - expat XML parser
    # -I/users/vbird/.usr/include
    whereIsExpat=`pkg-config --libs expat 2> /dev/null`
    if [[ "$whereIsExpat" != "" ]]; then
        # tmpPath=${whereIsExpat%%include*}       # -I/users/vbird/.usr
        # expatPath=${tmpPath#*I}                 # /users/vbird/.usr
        echo [Warning]: system already has libcurl installed, omitting it ...
        return
    fi

    expatInstDir=$commInstdir
    wgetLink=https://nchc.dl.sourceforge.net/project/expat/expat/2.2.5
    tarName=expat-2.2.5.tar.bz2
    untarName=expat-2.2.5

    # rename download package
    cd $downloadPath
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
}

installAsciidoc() {
    cat << "_EOF"
------------------------------------------------------
INSTALLING ASCIIDOC ...
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
    cd $downloadPath
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
    git checkout $checkoutVersion -f
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
INSTALLING XMLTO ...
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
    cd $downloadPath
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
START TO FIX DEPENDENCY ...
------------------------------------------------------
_EOF
    # Check if platform os type was passed from upper layer
    if [[ "$platOsType" == "" ]]; then
        platOsType=`sed -n '1p' /etc/issue | tr -s " " | cut -d " " -f 1 | \
            grep -i "[ubuntu|centos]"`
    fi

    case "$platOsType" in
        'Ubuntu' | 'ubuntu')
            echo "OS is Ubuntu..."
            sudo apt-get install libcurl4-openssl-dev \
                automake asciidoc xmlto libperl-dev \
                libssl-dev -y
            ;;

        'CentOS' | 'centos' | '\S' | 'Red' | 'redhat')
            echo "OS is CentOS or Red Hat..."
            sudo yum install libcurl-devel expat expat-devel \
                automake asciidoc xmlto perl-devel -y
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
INSTALLING GIT ...
------------------------------------------------------
_EOF
    gitInstDir=$commInstdir
    $execPrefix mkdir -p $commInstdir
    # comm attribute to get source 'git'
    gitClonePath=https://github.com/git/git
    clonedName=git
    # checkoutVersion=v2.15.0

    # rename download package
    cd $downloadPath
    # check if already has this tar ball.
    if [[ -d $clonedName ]]; then
        echo [Warning]: target $clonedName/ already exists, Omitting now ...
    else
        git clone ${gitClonePath} $clonedName --depth 1
        # check if git clone returns successfully
        if [[ $? != 0 ]]; then
            echo [Error]: git clone returns error, quiting now ...
            exit
        fi
    fi

    cd $clonedName
    # checkout to latest released tag
    git pull
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
    if [[ "$latestTag" != "" ]]; then
        git checkout $latestTag
    fi

    # run make routine
    make configure
    if [[ "$execPrefix" == "sudo" ]]; then
        ./configure --prefix=$gitInstDir --with-curl --with-expat
    else
        # --with-curl  support http(s):// transports (default is YES)
        # --with-expat support git-push using http:// and https://
        ./configure --prefix=$gitInstDir --with-curl --with-expat
    fi

    make all doc -j 1
    make all -j $cpuCoreNum
    # check if make returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: make returns error, quiting now ...
        exit
    fi

    # $execPrefix make install install-doc install-html
    $execPrefix make install
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
    mkdir -p $downloadPath
    source ~/.bashrc &> /dev/null

    checkCpuCoreNum
    installLibCurl
    installExpat
    installAsciidoc
    installXmlto
    installGit
}

case $1 in
    'home')
        set -x
        commInstdir=$homeInstDir
        execPrefix=""
        install
        ;;

    'root')
        set -x
        commInstdir=$rootInstDir
        execPrefix=sudo
        fixDepends
        install
        ;;

    *)
        set +x
        usage
        ;;
esac
