#!/bin/sh

set -x

if [[ -d .build/docker ]];
then
  rm -rf .build/docker
fi

mkdir -p .build/docker

# Find all gemspecs
if [[ -n "$(which rsync)" ]];
then
  rsync -zarvm --include='*/' --include='*.gemspec' --exclude='*' . .build/docker
else
  find . -name "*.gemspec" -exec cp --parents {} .build/docker/ \;
fi
