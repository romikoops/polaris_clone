#!/bin/bash

set -e

install=0
prepare=0

install() {
  if [ $install -eq 0 ];
  then
    echo "*** Install dependencies"
    bundle check || bundle install
    (
      cd client/
      npm install
    )
    install=1
  fi
}

prepare() {
  if [ $prepare -eq 0 ];
  then
    echo "*** Prepare database"
    bundle exec rake db:create db:test:prepare
    prepare=1
  fi
}

install
prepare

exec $*
