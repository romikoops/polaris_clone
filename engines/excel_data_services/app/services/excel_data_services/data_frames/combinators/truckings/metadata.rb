# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      module Truckings
        class Metadata < ExcelDataServices::DataFrames::Combinators::Base
          MetadataSheetIteration = Struct.new(:modifier_state, :metadata_state, keyword_init: true)

          def iterations
            @iterations ||= file.rate_schemas.map { |schema|
              MetadataSheetIteration.new(
                metadata_state: metadata_schema_state(schema: schema),
                modifier_state: modifiers_schema_state(schema: schema)
              )
            }
          end

          private

          def combined_state_frames(iteration:)
            iteration.metadata_state.frame
              .inner_join(iteration.modifier_state.frame, on: {"sheet_name" => "sheet_name"})
          end

          def combined_state_errors(iteration:)
            iteration.metadata_state.errors + iteration.modifier_state.errors
          end

          def metadata_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::Metadata.state(state: schema_state(schema: schema))
          end

          def modifiers_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::Modifiers.state(state: schema_state(schema: schema))
          end
        end
      end
    end
  end
end
