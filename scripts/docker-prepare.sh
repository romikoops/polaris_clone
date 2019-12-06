#!/bin/sh

if [ -d .build/docker ];
then
  rm -rf .build/docker
fi

mkdir -p .build/docker

# Find all gemspecs
if [ -n "$(command -v rsync)" ];
then
  rsync -zarvm --include='*/' --include='*.gemspec' --include='lib/engines/gemhelper.rb' --exclude='*' . .build/docker
else
  cp --parents lib/engines/gemhelper.rb .build/docker/
  find . -name "*.gemspec" -exec cp --parents {} .build/docker/ \;
fi
