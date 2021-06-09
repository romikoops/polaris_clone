# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Runners
      class Hubs < ExcelDataServices::DataFrames::Runners::Base
        def perform
          insert_nexuses
          insert_hubs
          return handle_errors if coordinator_errors.present?

          stats
        end

        def coordinator_errors
          @coordinator_errors ||= coordinator.errors + nexuses_coordinator.errors
        end

        def coordinator
          @coordinator ||= ExcelDataServices::DataFrames::Coordinators::Hubs::Hubs.state(
            state: runner_state
          )
        end

        def insert_hubs
          ExcelDataServices::DataFrames::Importers::Hubs.import(
            data: coordinator_frame,
            type: "hubs"
          ).tap { |import_result| merge_stats(result: import_result) }
        end

        def nexuses_coordinator
          ExcelDataServices::DataFrames::Coordinators::Hubs::Nexuses.state(
            state: runner_state
          )
        end

        def insert_nexuses
          ExcelDataServices::DataFrames::Importers::Nexuses.import(
            data: nexuses_coordinator.frame,
            type: "nexuses"
          ).tap { |import_result| merge_stats(result: import_result) }
        end
      end
    end
  end
end
