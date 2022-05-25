# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Distributors
      module Actions
        class AddValues < ExcelDataServices::V4::Distributors::Actions::Base
          def perform
            return frame if affected_rows.empty?

            frame.left_join(result_frame, on: { "row" => "row", "sheet_name" => "sheet_name", "organization_id" => "organization_id" })
          end

          private

          def result_frame
            @result_frame ||= Rover::DataFrame.new(affected_rows[%w[row sheet_name organization_id]].to_a.uniq).tap do |dupped_frame|
              arguments.each do |key, value|
                dupped_frame[key] = value
              end
            end
          end
        end
      end
    end
  end
end
