# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Sheet
      class TruckingFees < ExcelDataServices::Schemas::Sheet::Base
        SCHEMA = YAML.load_file(File.expand_path("../data/trucking_fees.yml", __dir__)).freeze

        def schema
          SCHEMA
        end
      end
    end
  end
end
