#!/bin/bash

#----------------------------------------------------------------------------#
#  __    _____ _____
# |  |  |   __|   __|
# |  |__|   __|__   |
# |_____|__|  |_____|
#
# Automate LFS Build
#----------------------------------------------------------------------------#
# (C) 2019-2022 Ranjith Gowda, Jansen Price
# https://github.com/ranjithum/automate-lfs-build
#----------------------------------------------------------------------------#
# Usage: ./01-version-check.sh
# This script will perform some preliminary checks to determine if the host
# machine has the ncessary tools to build the remaining toolchain and packages.
# If a required program does not exist, it will show as an error. Otherwise it
# will print the current version. It is up to the user to visually check the
# versions from the output of each program compared to the minimum requirements
# for lfs.
#----------------------------------------------------------------------------#

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[1]}")" &> /dev/null && pwd)
. $REPO_ROOT/common/common_utils

# -----------------
# Utility functions
# -----------------
assert_has() {
    check_label=$([ -n "$2" ] && echo "$2" || echo "$1")
    printf "Checking for $check_label ... "
    has_in_path=$(which $1 2>/dev/null)
    if [ -z "$has_in_path" ]; then
        error "$1 not found"
        HAS_ERROR=1
        return 1
    fi
    return 0
}

# -----------------
# Main
# -----------------

HAS_ERROR=0
export LC_ALL=C

echo "------------ LFS VERSION CHECK ------------"

assert_has bash && success $(bash --version | head -n1 | cut -d" " -f2-4)
printf "Checking that /bin/sh -> bash ... "
is_linked=$(readlink -f /bin/sh | grep bash)
if [ -z "$is_linked" ]; then
    error "/bin/sh does not point to bash"
else
    success OK
fi

assert_has ld "Binutils" && success $(ld --version | head -n1 | cut -d" " -f3-)

assert_has bison && success $(bison --version | head -n1)
printf "Checking that /usr/bin/yacc -> bison ... "
if [ -h /usr/bin/yacc ]; then
    success "/usr/bin/yacc -> $(readlink -f /usr/bin/yacc)"
elif [ -x /usr/bin/yacc ]; then
    success "yacc is $(/usr/bin/yacc -V | head -n1)"
else
    error "yacc not found"
fi

assert_has bzip2 && success $(bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-)
assert_has chown "Coreutils" && success $(chown --version | head -n1 | cut -d"(" -f2)
assert_has diff "Diffutils" && success $(diff --version | head -n1)
assert_has find "Findutils" && success $(find --version | head -n1)
assert_has gawk && success $(gawk --version | head -n1)

printf "Checking that /usr/bin/awk -> gawk ... "
if [ -h /usr/bin/awk ]; then
    success "/usr/bin/awk -> $(readlink -f /usr/bin/awk)"
elif [ -x /usr/bin/awk ]; then
    success "awk is $(/usr/bin/awk --version | head -n1)"
else
    error "awk not found"
fi

HAS_GPP=0
assert_has gcc && success $(gcc --version | head -n1)
assert_has g++ && HAS_GPP=1 && success $(g++ --version | head -n1)
assert_has ldd glibc && success $(ldd --version | head -n1 | cut -d" " -f2-)
assert_has grep && success $(grep --version | head -n1)
assert_has gzip && success $(gzip --version | head -n1)
printf "Kernel: "; success $(cat /proc/version)
assert_has m4 && success $(m4 --version | head -n1)
assert_has make && success $(make --version | head -n1)
assert_has patch && success $(patch --version | head -n1)
assert_has perl && success $(perl -V:version)
assert_has python3 && success $(python3 --version)
assert_has sed && success $(sed --version | head -n1)
assert_has tar && success $(tar --version | head -n1)
assert_has makeinfo texinfo && success $(makeinfo --version | head -n1)
assert_has xz && success $(xz --version | head -n1)

if [ $HAS_GPP -eq 1 ]; then
    printf "Checking g++ compilation ... "
    echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
    if [ -x dummy ]
        then success "g++ compilation OK";
        else error "g++ compilation failed"; HAS_ERROR=1; fi
    rm -f dummy.c dummy
fi

echo "-------------------------------------------"
exit $HAS_ERROR
