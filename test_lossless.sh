#!/bin/sh
##
## test_lossless.sh
##
## Simple test to validate decoding of lossless test vectors using
## the dwebp example utility.
##
## This file distributed under the same terms as libwebp. See the libwebp
## COPYING file for more information.
##

self=$0
usage() {
    echo "Usage: $self [--exec=/path/to/dwebp]"
    exit 1
}

for opt; do
    optval=${opt##*=}
    case ${opt} in
        --exec=*) executable="${optval}";;
        *) usage;;
    esac
done
test_file_dir=$(dirname $self)

executable=${executable:-dwebp}
${executable} 2>/dev/null | grep -q Usage || usage

for i in `seq 0 15`; do
    file="$test_file_dir/lossless_vec_1_$i.webp"
    ${executable} $file -o test.pam -pam
    diff test.pam $test_file_dir/grid.pam || exit -1
done

for i in `seq 0 15`; do
    file="$test_file_dir/lossless_vec_2_$i.webp"
    ${executable} $file -o test.pam -pam
    diff test.pam $test_file_dir/peak.pam || exit -1
done

rm -f test.pam