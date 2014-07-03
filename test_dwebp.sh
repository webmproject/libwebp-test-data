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
Usage: $self [options] [/path/to/libwebp_tests.md5]

Options:
  --exec=/path/to/dwebp
  --mt
  --formats=format_list (default: $formats)
EOT
    exit 1
}

# Decode $1 and verify against md5s.
check() {
    local f="$1"
    shift
    # Decode the file to the requested formats.
    for fmt in $formats; do
      eval ${executable} ${mt} -${fmt} "$@" -o "${f}.${fmt}" "$f" ${devnull}
    done

    # Check the md5sums
    grep ${f##*/} "$tests" | (cd $(dirname $f); md5sum -c -) || exit 1

    # Clean up.
    for fmt in $formats; do
      rm -f "${f}.${fmt}"
    done
}

# PPM (RGB), PAM (RGBA), PGM (YUV), BMP (BGRA/BGR), TIFF (rgbA/RGB)
formats="ppm pam pgm bmp tiff"
mt=""
devnull="> /dev/null 2>&1"
for opt; do
    optval=${opt#*=}
    case ${opt} in
        --exec=*) executable="${optval}";;
        --formats=*) formats="${optval}";;
        --mt) mt="-mt";;
        -v) devnull="";;
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
for f in $(awk '{print $2}' "$tests" | sed -e 's,webp\..*$,webp,' | uniq); do
    f="${test_dir}/${f}"
    check "$f"

    # Decode again, without optimization this time
    check "$f" -noasm
done
