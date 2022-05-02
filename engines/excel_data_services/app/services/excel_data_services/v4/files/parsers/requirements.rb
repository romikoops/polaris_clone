# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Requirements < ExcelDataServices::V4::Files::Parsers::Base
          SPLIT_PATTERN = /^(required)/.freeze

          def requirements
            @requirements ||= []
          end

          def required(rows, columns, content)
            @requirements = non_empty_sheets.map do |sheet_name|
              ExcelDataServices::V4::Files::Requirement.new(rows: rows, columns: columns, content: content, sheet_name: sheet_name, xlsx: xlsx)
            end
          end
        end
      end
    end
  end
end
