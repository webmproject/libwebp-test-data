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
set -e

self=$0
usage() {
    echo "Usage: $self [--exec=/path/to/dwebp]"
    exit 1
}

# Decode $1 as a pam and compare to $2. Additional parameters are passed to the
# executable.
check() {
    local infile="$1"
    local reffile="$2"
    local outfile="$infile.${reffile##*.}"
    shift 2
    eval ${executable} "$infile" -o "$outfile" "$@" ${devnull}
    diff -s "$outfile" "$reffile"
    rm -f "$outfile"
}

devnull="> /dev/null 2>&1"
for opt; do
    optval=${opt#*=}
    case ${opt} in
        --exec=*) executable="${optval}";;
        -v) devnull="";;
        *) usage;;
    esac
done
test_file_dir=$(dirname $self)

executable=${executable:-dwebp}
${executable} 2>/dev/null | grep -q Usage || usage

for i in `seq 0 15`; do
    file="$test_file_dir/lossless_vec_1_$i.webp"
    check "$file" "$test_file_dir/grid.pam" -pam
    check "$file" "$test_file_dir/grid.pam" -pam -noasm
done

for i in `seq 0 15`; do
    file="$test_file_dir/lossless_vec_2_$i.webp"
    check "$file" "$test_file_dir/peak.pam" -pam
    check "$file" "$test_file_dir/peak.pam" -pam -noasm
done

file="$test_file_dir/lossless_color_transform.webp"
check "$file" "$test_file_dir/lossless_color_transform.ppm" -ppm
check "$file" "$test_file_dir/lossless_color_transform.ppm" -ppm -noasm

echo "ALL TESTS OK"
