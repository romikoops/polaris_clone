# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      module Truckings
        class Rates < ExcelDataServices::DataFrames::Combinators::Base
          RatesSheetIteration = Struct.new(
            :brackets_state,
            :bracket_minimums_state,
            :modifiers_state,
            :values_state,
            :zone_minimums_state,
            :zone_rows_state,
            :metadata_state,
            keyword_init: true
          )

          def iterations
            @iterations ||= file.rate_schemas.map do |schema|
              RatesSheetIteration.new(
                brackets_state: brackets_schema_state(schema: schema),
                bracket_minimums_state: bracket_minimums_schema_state(schema: schema),
                modifiers_state: modifiers_schema_state(schema: schema),
                values_state: values_schema_state(schema: schema),
                zone_minimums_state: zone_minimums_schema_state(schema: schema),
                zone_rows_state: zone_rows_schema_state(schema: schema),
                metadata_state: metadata_schema_state(schema: schema)
              )
            end
          end

          private

          def combined_state_frames(iteration:)
            iteration.values_state.frame
              .inner_join(iteration.modifiers_state.frame, on: { "value_col" => "modifier_col" })
              .inner_join(iteration.zone_rows_state.frame, on: { "value_row" => "zone_row" })
              .inner_join(iteration.brackets_state.frame, on: { "value_col" => "bracket_col" })
              .left_join(iteration.zone_minimums_state.frame, on: { "value_row" => "zone_minimum_row" })
              .inner_join(iteration.bracket_minimums_state.frame, on: { "value_col" => "bracket_minimum_col" })
              .inner_join(iteration.metadata_state.frame, on: { "sheet_name" => "sheet_name" })
          end

          def combined_state_errors(iteration:)
            [iteration.values_state,
              iteration.modifiers_state,
              iteration.zone_rows_state,
              iteration.brackets_state,
              iteration.zone_minimums_state,
              iteration.bracket_minimums_state].map(&:errors).flatten
          end

          def brackets_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::Brackets.state(state: schema_state(schema: schema))
          end

          def bracket_minimums_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::BracketMinimum.state(
              state: schema_state(schema: schema)
            )
          end

          def modifiers_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::Modifiers.state(state: schema_state(schema: schema))
          end

          def values_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::Values.state(state: schema_state(schema: schema))
          end

          def zone_minimums_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::ZoneMinimum.state(state: schema_state(schema: schema))
          end

          def zone_rows_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::ZoneRow.state(state: schema_state(schema: schema))
          end

          def metadata_schema_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::Metadata.state(state: schema_state(schema: schema))
          end
        end
      end
    end
  end
end
