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
  find . -name "*.gemspec" -exec cp --parents {} .build/docker/ \;
  find . -name "lib/engines/gemhelper.rb" -exec cp --parents {} .build/docker/ \;
fi
