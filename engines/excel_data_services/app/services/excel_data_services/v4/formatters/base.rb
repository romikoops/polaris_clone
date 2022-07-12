# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class Base
        attr_reader :state

        delegate :frame, to: :state

        def self.state(state:)
          new(state: state).perform
        end

        def initialize(state:)
          @state = state
        end

        def perform
          @state.insertable_data = insertable_data
          @state
        end

        def upsert_id(row:)
          ::UUIDTools::UUID.sha1_create(
            self.class::NAMESPACE_UUID,
            row.values_at(*self.class::UUID_KEYS).map(&:to_s).join
          ).to_s
        end

        def rows_for_insertion
          @rows_for_insertion ||= frame.include?(target_attribute) ? frame[frame[target_attribute].missing] : frame
        end
      end
    end
  end
end
