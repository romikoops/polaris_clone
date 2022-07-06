# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Operations < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[operations].freeze

          def operations
            @operations ||= schema_data[:operations].flat_map do |operation|
              target_frames_or_default(input: operation).map do |target_frame|
                ExcelDataServices::V4::Files::Parsers::ActionWrapper.new(
                  action: "ExcelDataServices::V4::Operations::#{operation[:type]}".constantize,
                  target_frame: target_frame
                )
              end
            end
          end
        end
      end
    end
  end
end
