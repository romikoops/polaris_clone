# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Overlaps
      class Resolver
        DATE_KEYS = %w[effective_date expiration_date].freeze

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

          ExcelDataServices::V4::Overlaps::Clearer.new(
            frame: frame, model: model, conflict_keys: keys
          ).perform
          state
        end

        private

        attr_reader :state, :keys, :model

        def frame
          @frame ||= state.frame("default")
        end

        def append_internal_conflict_rows
          frame.group_by(keys).each do |sub_frame|
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
          @state.errors << ExcelDataServices::V4::Error.new(
            type: :error,
            row_nr: row_list,
            sheet_name: rows.dig(0, "sheet_name"),
            reason: "The rows listed have conflicting validity dates. Please correct before reuploading.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
