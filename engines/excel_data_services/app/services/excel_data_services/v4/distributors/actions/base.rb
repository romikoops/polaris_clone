# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Distributors
      module Actions
        class Base
          def initialize(frame:, action:)
            @frame = frame
            @action = action
          end

          attr_reader :frame, :action

          private

          delegate :where, :arguments, :organization, :target_organization, to: :action

          def affected_rows
            @affected_rows ||= frame.filter(adjusted_where_filter)
          end

          def adjusted_where_filter
            where.merge("organization_id" => target_organization.id)
          end
        end
      end
    end
  end
end
