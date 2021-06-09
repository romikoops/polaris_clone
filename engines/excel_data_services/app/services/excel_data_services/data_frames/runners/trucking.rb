# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Runners
      class Trucking < ExcelDataServices::DataFrames::Runners::Base
        def perform
          return handle_errors if coordinator_errors.present?

          insert_truckings
          insert_type_availabilities
          insert_hub_availabilities
          stats
        end

        def coordinator
          @coordinator ||= ExcelDataServices::DataFrames::Coordinators::Trucking.state(
            state: runner_state
          )
        end

        def insert_truckings
          ExcelDataServices::DataFrames::Importers::Trucking.import(
            data: coordinator_frame,
            type: "truckings"
          ).tap { |import_result| merge_stats(result: import_result) }
        end

        def type_availabilities_coordinator
          ExcelDataServices::DataFrames::Coordinators::Truckings::TypeAvailabilities.state(
            state: runner_state
          )
        end

        def hub_availabilities_coordinator
          ExcelDataServices::DataFrames::Coordinators::Truckings::HubAvailabilities.state(
            state: runner_state
          )
        end

        def insert_type_availabilities
          ExcelDataServices::DataFrames::Importers::TypeAvailabilities.import(
            data: type_availabilities_coordinator.frame,
            type: "type_availabilities"
          ).tap { |import_result| merge_stats(result: import_result) }
        end

        def insert_hub_availabilities
          ExcelDataServices::DataFrames::Importers::HubAvailabilities.import(
            data: hub_availabilities_coordinator.frame,
            type: "hub_availabilities"
          ).tap { |import_result| merge_stats(result: import_result) }
        end
      end
    end
  end
end
