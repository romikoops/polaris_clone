# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      module Truckings
        class Fees < ExcelDataServices::DataFrames::Combinators::Base
          def iterations
            @iterations ||= [
              DefaultSheetIteration.new(
                default_state: ExcelDataServices::DataFrames::Processors::Trucking::Fees.state(
                  state: schema_state(schema: file.fee_schema)
                )
              )
            ]
          end
        end
      end
    end
  end
end
