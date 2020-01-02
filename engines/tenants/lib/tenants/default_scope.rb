# frozen_string_literal: true

module Tenants
  DEFAULT_SCOPE = YAML.load_file(File.expand_path('../../data/default_scope.yaml', __dir__)).freeze
end
