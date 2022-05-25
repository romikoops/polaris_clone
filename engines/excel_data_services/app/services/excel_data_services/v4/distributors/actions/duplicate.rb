# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Distributors
      module Actions
        class Duplicate < ExcelDataServices::V4::Distributors::Actions::Base
          def perform
            frame.concat(duplicated_rows)
          end

          private

          def duplicated_rows
            @duplicated_rows ||= affected_rows.dup.tap do |dupped_frame|
              dupped_frame["organization_id"] = target_organization.id
            end
          end

          def adjusted_where_filter
            where.merge("organization_id" => organization.id)
          end
        end
      end
    end
  end
end
