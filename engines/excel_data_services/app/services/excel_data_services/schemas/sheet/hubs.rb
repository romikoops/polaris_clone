# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Sheet
      class Hubs < ExcelDataServices::Schemas::Sheet::Base
        SCHEMA = YAML.load_file(File.expand_path("../data/hubs.yml", __dir__)).freeze

        def schema
          SCHEMA
        end
      end
    end
  end
end
