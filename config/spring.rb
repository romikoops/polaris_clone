# frozen_string_literal: true

# puts 'Workaround to ignore directories. Doesn\'t work currently.'
# Spring::Watcher::Listen.class_eval do
#   def base_directories
#     ([root] +
#       files.reject       { |f| f.start_with? "#{root}/" }.map { |f| File.expand_path("#{f}/..") } +
#       directories.reject { |d| d.start_with? "#{root}/" }
#     ).uniq.map { |path| Pathname.new(path) }
#     .reject { |p| p == "client" }
#   end
# end

### Above was added. Below is standard.

%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }
