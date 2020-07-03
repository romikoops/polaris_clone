# frozen_string_literal: true

require "migrator/engine"

require "migrator/base"
require "migrator/dependency"
require "migrator/runner"

Dir.glob(File.expand_path("migrator/migrations/**/*.rb", __dir__)).sort.each do |f|
  require f
end
