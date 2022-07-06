# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class DataValidators < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[data_validators].freeze

          def data_validations
            @data_validations ||= (schema_data[:data_validators] || []).flat_map do |validator|
              validator[:frames].map do |target_frame|
                ExcelDataServices::V4::Files::Parsers::ActionWrapper.new(
                  action: "ExcelDataServices::V4::Validators::#{validator[:type]}".constantize,
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
