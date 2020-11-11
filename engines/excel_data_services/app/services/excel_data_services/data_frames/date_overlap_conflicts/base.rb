# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DateOverlapConflicts
      class Base < ExcelDataServices::DataFrames::Base
        def perform
          check_validities if state.errors.empty?
          state
        end

        def check_validities
          frame[conflict_keys].to_a.uniq.each do |conflict_targets|
            conflicts = overlaps(arguments: conflict_targets)
            handle_overlaps(conflicts: conflicts, arguments: conflict_targets) if conflicts.present?
          end
        end

        def overlaps(arguments:)
          ExcelDataServices::DataFrames::DateOverlapConflicts::Conflicts.conflicts(
            table: target_table, arguments: arguments
          )
        end

        def handle_overlaps(conflicts:, arguments:)
          conflicts.keys.select { |key| conflicts[key].present? }.each do |conflict_type|
            overlap_class(conflict_type: conflict_type).new(model: model, arguments: arguments).perform
          end
        end

        def overlap_class(conflict_type:)
          ExcelDataServices::Overlaps.const_get(conflict_type.camelize)
        end

        def conflict_keys
          raise NotImplementedError, "This method must be implemented in #{self.class.name} "
        end
      end
    end
  end
end
