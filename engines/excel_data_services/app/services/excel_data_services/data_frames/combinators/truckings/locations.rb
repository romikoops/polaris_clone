# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      module Truckings
        class Locations < ExcelDataServices::DataFrames::Combinators::Base
          def iterations
            @iterations ||= [
              DefaultSheetIteration.new(
                default_state: ExcelDataServices::DataFrames::Processors::Trucking::Zones.state(
                  state: schema_state(schema: file.zone_schema)
                )
              )
            ]
          end
        end
      end
    end
  end
end
