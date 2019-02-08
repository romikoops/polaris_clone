# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Syntax
      class Base
        include ExcelDataServices::DataValidator

        StructureError = Class.new(ValidationError)
        InvalidHeadersError = Class.new(StructureError)

        def perform
          data.each do |sheet_name, sheet_data|
            check_sheet(sheet_name, sheet_data)

            sheet_data[:rows_data].each do |row_data|
              check_row(row_data)
            end
          end

          errors
        end

        private

        def check_sheet(sheet_name, sheet_data)
          check_headers(sheet_name, sheet_data)
        end

        def check_headers(sheet_name, sheet_data)
          headers = get_headers(sheet_data)
          begin
            validate_headers(headers, sheet_name, sheet_data[:data_extraction_method])
          rescue InvalidHeadersError => exception
            add_to_errors(row_nr: 1, reason: exception.message)
          end
        end

        def get_headers(sheet_data)
          sheet_data[:rows_data].first.keys
        end

        def validate_headers(headers, sheet_name, data_extraction_method)
          valid_headers = build_valid_headers(data_extraction_method)
          passing_headers = valid_headers.select.with_index { |el, i| el == headers[i] }
          failing_headers_indices = valid_headers.each_with_object([]).with_index do |(el, indices), i|
            indices << i if el != headers[i]
          end
          failing_headers = headers.values_at(*failing_headers_indices)
          failing_headers_sould_be = valid_headers - passing_headers

          unless failing_headers.blank?
            raise InvalidHeadersError, "The following headers of sheet \"#{sheet_name}\" are not valid:\n" \
                                       "IS       : \"#{failing_headers.map(&:upcase).join(', ')}\",\n" \
                                       "SHOULD BE: \"#{failing_headers_sould_be.map(&:upcase).join(', ')}\""
          end

          true
        end

        def build_valid_headers
          raise NotImplementedError, "This method must be implemented in #{self.class.name}."
        end

        def check_row(row_data)
          unless block_given?
            raise ArgumentError, "This method (#{__method__}) in #{self.class.name}" \
                                       " doesn't provide a block to itself's definition in the superclass."
          end

          row = ExcelDataServices::Row.get(klass_identifier).new(row_data: row_data, tenant: tenant)
          yield(row)
        rescue ValidationError => exception
          add_to_errors(row_nr: row.nr, reason: exception.message)
        end
      end
    end
  end
end
