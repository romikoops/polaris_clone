# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Combinators::Base
          def iterations
            @iterations ||= [
              DefaultSheetIteration.new(
                default_state: ExcelDataServices::DataFrames::Processors::Hubs::Hubs.state(
                  state: schema_state(schema: file.schema)
                )
              )
            ]
          end
        end
      end
    end
  end
end
