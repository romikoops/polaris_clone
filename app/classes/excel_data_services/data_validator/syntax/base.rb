# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Syntax
      class Base
        SyntaxError = Class.new(StandardError)
        InvalidHeadersError = Class.new(SyntaxError)

        def self.validate(options)
          new(options).perform
        end

        def initialize(data:, tenant:)
          @data = data
          @tenant = tenant
          @errors = []
        end

        def perform
          data.each do |sheet_name, sheet_data|
            headers = get_headers(sheet_data)
            begin
              validate_headers(headers, sheet_name, sheet_data[:data_extraction_method])
            rescue InvalidHeadersError => exception
              add_to_errors(row_nr: 1, reason: exception.message)
            end

            sheet_data[:rows_data].each do |row_data|
              row = ExcelDataServices::Row::Base.new(row_data: row_data, tenant: tenant)

              begin
                if block_given?
                  yield(row)
                else
                  raise NotImplementedError, "This method is either not implemented in #{self.class.name}" \
                                             ", or doesn't provide a block to its superclass method."
                end
              rescue SyntaxError => exception
                add_to_errors(row_nr: row.nr, reason: exception.message)
              end
            end
          end

          errors
        end

        private

        attr_reader :data, :tenant, :errors

        def add_to_errors(row_nr:, reason:)
          @errors << { row_nr: row_nr,
                       reason: reason }
        end

        def get_headers(sheet_data)
          sheet_data[:rows_data].first.keys
        end

        def build_valid_headers
          raise NotImplementedError, "This method must be implemented in #{self.class.name}."
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
      end
    end
  end
end
