#!/bin/sh -e

rm -rf tmp/docker
mkdir -p tmp/docker
find . -depth -type f -name '*.gemspec' | cpio -d -v -p .build/
