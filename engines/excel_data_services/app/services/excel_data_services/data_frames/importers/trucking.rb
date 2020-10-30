# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Importers
      class Trucking < ExcelDataServices::DataFrames::Importers::Base
        def model
          ::Trucking::Trucking
        end

        def options
          {
            batch_size: BATCH_SIZE,
            all_or_none: true
          }
        end
      end
    end
  end
end
