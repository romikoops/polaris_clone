# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Importers
      class Base
        BATCH_SIZE = 2000

        def self.import(data:, type:)
          new(data: data, type: type).perform
        end

        def initialize(data:, type:)
          @data = data
          @type = type
        end

        def perform
          import_result
          stats
        end

        private

        attr_reader :data, :type

        def import_result
          @import_result ||= model.import(
            data.to_a,
            options
          )
        end

        def stats
          ExcelDataServices::DataFrames::Importers::Stats.new(
            type: type,
            created: import_result.ids.count,
            failed: import_result.failed_instances.count,
            errors: import_errors
          )
        end

        def import_errors
          import_result.failed_instances.map { |failed|
            {
              sheet_name: type,
              reason: failed.errors.to_a.join(", ")
            }
          }
        end

        def options
          raise NotImplementedError, "This method must be implemented in #{self.class.name}"
        end

        def model
          raise NotImplementedError, "This method must be implemented in #{self.class.name}"
        end
      end
    end
  end
end
