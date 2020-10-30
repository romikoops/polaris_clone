# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Sheet
      class TruckingZones < ExcelDataServices::Schemas::Sheet::Base
        SCHEMA = YAML.load_file(File.expand_path("../data/trucking_zones.yml", __dir__)).freeze

        def schema
          SCHEMA
        end
      end
    end
  end
end
