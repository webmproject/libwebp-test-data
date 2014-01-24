#!/bin/sh
##
## test_dwebp.sh
##
## Author: John Koleszar <jkoleszar@google.com>
##
## Simple test driver for validating (via md5 sum) the output of the libwebp
## dwebp example utility.
##
## This file distributed under the same terms as libwebp. See the libwebp
## COPYING file for more information.
##

self=$0

usage() {
    cat <<EOT
Usage: $self [--exec=/path/to/dwebp] [--mt] /path/to/libwebp_tests.md5
EOT
    exit 1
}

mt=""
for opt; do
    optval=${opt##*=}
    case ${opt} in
        --exec=*) executable="${optval}";;
        --mt) mt="-mt";;
        -*) usage;;
        *) [ -z "$tests" ] || usage; tests="$opt";;
    esac
done

# Validate test file
if [ -z "$tests" ]; then
    [ -f "$(dirname $self)/libwebp_tests.md5" ] && tests="$(dirname $self)/libwebp_tests.md5"
fi
[ -f "$tests" ] || usage

# Validate test executable
executable=${executable:-dwebp}
${executable} 2>/dev/null | grep -q Usage || usage

test_dir=$(dirname ${tests})
for f in $(awk '{print $2}' "$tests" | sed -e 's,webp\....,webp,' | uniq); do
    f="${test_dir}/${f}"

    # Decode the file to PPM and YUV
    ${executable} ${mt} -ppm -o "${f}.ppm" "$f" > /dev/null 2>&1
    ${executable} ${mt} -pgm -o "${f}.pgm" "$f" > /dev/null 2>&1

    # Check the md5sums
    grep ${f##*/} "$tests" | (cd $(dirname $f); md5sum -c -)

    # Clean up.
    rm -f "${f}.pgm" "${f}.ppm"

    # Decode again, without optimization this time
    ${executable} ${mt} -noasm -ppm -o "${f}.ppm" "$f" > /dev/null 2>&1
    ${executable} ${mt} -noasm -pgm -o "${f}.pgm" "$f" > /dev/null 2>&1
    grep ${f##*/} "$tests" | (cd $(dirname $f); md5sum -c -)
    rm -f "${f}.pgm" "${f}.ppm"
done
