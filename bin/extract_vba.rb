#!/usr/bin/env ruby
# frozen_string_literal: true

#
# This file was generated by Bundler.
#
# The application 'extract_vba.rb' is installed as part of a gem, and
# this file is here to facilitate running it.
#

require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile",
  Pathname.new(__FILE__).realpath)

bundle_binstub = File.expand_path("../bundle", __FILE__)

if File.file?(bundle_binstub)
  if File.read(bundle_binstub, 150) =~ /This file was generated by Bundler/
    load(bundle_binstub)
  else
    abort("Your `bin/bundle` was not generated by Bundler, so this binstub cannot run.
Replace `bin/bundle` by running `bundle binstubs bundler --force`, then run this command again.")
  end
end

require "rubygems"
require "bundler/setup"

load Gem.bin_path("write_xlsx", "extract_vba.rb")
