# frozen_string_literal: true

require "organizations/engine"

module Organizations
  DEFAULT_SCOPE = YAML.load_file(File.expand_path("../data/default_scope.yaml", __dir__)).freeze
  DEFAULT_COLOR_SCHEMA = YAML.load_file(File.expand_path("../data/default_color_scheme.yaml", __dir__)).freeze

  class << self
    def current_id=(id)
      RequestStore.store[:organization_id] = id
    end

    def current_id
      RequestStore.store[:organization_id]
    end
  end
end
