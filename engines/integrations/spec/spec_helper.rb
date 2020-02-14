# frozen_string_literal: true

require 'json-schema'

Dir[File.join(File.expand_path('../../../lib/spec/support', __dir__), '**', '*.rb')].sort.each { |f| require f }

SimpleCov.start do
  command_name File.dirname(File.expand_path('../', __dir__))
end
