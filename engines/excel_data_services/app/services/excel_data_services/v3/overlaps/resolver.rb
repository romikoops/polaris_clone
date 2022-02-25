# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Overlaps
      class Resolver
        # The Resolver class will take the conflict keys andd extract the permutations from the data frame.
        # It will then find all conflicts that exists for each pair and execute the Overlaps handler for that conflict type
        include Sidekiq::Status::Worker

        DATE_KEYS = %w[effective_date expiration_date].freeze
        delegate :frame, to: :state

        def self.state(state:, model:, keys:)
          new(state: state, model: model, keys: keys).perform
        end

        def initialize(state:, model:, keys:)
          @state = state
          @model = model
          @keys = keys
        end

        def perform
          append_internal_conflict_rows
          return state if state.errors.present?

          frame[conflict_keys].to_a.uniq.each do |conflict_targets|
            handle_overlap(arguments: conflict_targets)
          end
          state
        end

        private

        attr_reader :state, :keys, :model

        def handle_overlap(arguments:)
          ExcelDataServices::V3::Overlaps::Detector.overlaps(
            table: model.table_name, arguments: arguments
          ).each do |conflict_type|
            ExcelDataServices::V3::Overlaps.const_get(conflict_type.camelize).new(model: model, arguments: arguments).perform
          end
        end

        def append_internal_conflict_rows
          frame[keys].to_a.uniq.each do |indentifying_attributes|
            sub_frame = frame.filter(indentifying_attributes)
            add_internal_conflict_error(rows: sub_frame.to_a) if internal_conflict_exists(sub_frame: sub_frame)
          end
        end

        def internal_conflict_exists(sub_frame:)
          sub_frame[DATE_KEYS].to_a.uniq.combination(2).any? do |row_a, row_b|
            Range.new(*row_a.values_at(*DATE_KEYS)).overlaps?(Range.new(*row_b.values_at(*DATE_KEYS)))
          end
        end

        def add_internal_conflict_error(rows:)
          row_list = rows.pluck("row").to_a.uniq.join(", ")
          @state.errors << ExcelDataServices::V3::Error.new(
            type: :error,
            row_nr: row_list,
            sheet_name: rows.dig(0, "sheet_name"),
            reason: "The rows listed have conflicting validity dates. Please correct before reuploading.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end

        def conflict_keys
          keys + DATE_KEYS
        end
      end
    end
  end
end
