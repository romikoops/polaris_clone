# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class DataValidators < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[data_validators].freeze

          def data_validations
            @data_validations ||= (schema_data[:data_validators] || []).map do |validator|
              "ExcelDataServices::V4::Validators::#{validator}".constantize
            end
          end
        end
      end
    end
  end
end
