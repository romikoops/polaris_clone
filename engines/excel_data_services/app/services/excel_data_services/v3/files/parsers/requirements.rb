# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Parsers
        class Requirements < ExcelDataServices::V3::Files::Parsers::Base
          SPLIT_PATTERN = /^(required)/.freeze

          def requirements
            @requirements ||= []
          end

          def required(rows, columns, content)
            @requirements = non_empty_sheets.map do |sheet_name|
              ExcelDataServices::V3::Files::Requirement.new(rows: rows, columns: columns, content: content, sheet_name: sheet_name, xlsx: xlsx)
            end
          end
        end
      end
    end
  end
end
