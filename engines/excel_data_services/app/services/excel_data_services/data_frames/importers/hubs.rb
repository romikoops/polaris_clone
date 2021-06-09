# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Importers
      class Hubs < ExcelDataServices::DataFrames::Importers::Base
        def model
          ::Legacy::Hub
        end

        def options
          {
            batch_size: BATCH_SIZE,
            on_duplicate_key_ignore: true
          }
        end
      end
    end
  end
end
