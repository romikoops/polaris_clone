#!/bin/sh -e

rm -rf tmp/docker/
rsync -vtrla --progress --partial --prune-empty-dirs --include='*/' --include="*.gemspec" --exclude='*' "." "tmp/docker/"
