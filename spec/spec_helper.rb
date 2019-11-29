# frozen_string_literal: true

Dir[File.join(File.expand_path('../lib/spec/support', __dir__), '**', '*.rb')].each { |f| require f }

SimpleCov.start do
  command_name File.dirname(File.expand_path('../', __dir__))

  # Ignore Engine Helpers
  add_filter %r{^/lib/engines/}
end
