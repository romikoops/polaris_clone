# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Combinators
      module Truckings
        class TypeAvailabilities < ExcelDataServices::DataFrames::Combinators::Base
          TypeAvailabilitySheetIteration = Struct.new(:type_availability_state, :country_code_state, keyword_init: true)

          def iterations
            @iterations ||= file.rate_schemas.map { |schema|
              TypeAvailabilitySheetIteration.new(
                type_availability_state: type_availability_state(schema: schema)
              )
            }
          end

          private

          def combined_state_errors(iteration:)
            iteration.type_availability_state.errors
          end

          def combined_state_frames(iteration:)
            type_availability_frame = iteration.type_availability_state.frame
            join_key = iteration.type_availability_state.schema.sheet_name
            type_availability_frame[:join_key] = join_key
            countries_frame[:join_key] = join_key
            result = type_availability_frame.inner_join(countries_frame, on: :join_key)
            result.delete(:join_key)
            result
          end

          def country_code_state
            @country_code_state ||= ExcelDataServices::DataFrames::DataProviders::Trucking::CountryCodes.state(
              state: schema_state(schema: country_code_schema)
            )
          end

          def country_code_schema
            file.zone_schema
          end

          def countries_frame
            @countries_frame ||= Rover::DataFrame.new(country_data)
              .inner_join(country_code_state.frame, on: {"country_code" => "country_code"})
          end

          def country_data
            Legacy::Country.select("id AS country_id, code AS country_code")
          end

          def type_availability_state(schema:)
            ExcelDataServices::DataFrames::Processors::Trucking::TypeAvailabilities.state(
              state: schema_state(schema: schema)
            )
          end
        end
      end
    end
  end
end
