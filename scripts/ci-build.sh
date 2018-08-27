#!/bin/bash

set -e

install=0
prepare=0

: ${RAILS_ENV:=test}
: ${RACK_ENV:=test}
export RAILS_ENV RACK_ENV

export SPEC_OPTS="--format RspecJunitFormatter --out rspec.xml --format Fuubar --color"

install() {
  if [ $install -eq 0 ];
  then
    echo "*** Install dependencies"
    bundle check || bundle install --without development
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
