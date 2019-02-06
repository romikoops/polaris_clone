#!/bin/sh -e

rm -rf .build
mkdir -p .build
find . -depth -type f -name '*.gemspec' | cpio -d -v -p .build/
