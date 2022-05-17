# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Xml < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[xml_columns xml_data].freeze

          def xml_data
            @xml_data ||= ExcelDataServices::V4::Files::XmlData.new(xml: xml, path: context[:path], schema: context[:schema])
          end

          def xml_columns
            @xml_columns ||= if state.xml?
              schema_data[:xml_columns].product(identifiers).map do |datum, identifier|
                ExcelDataServices::V4::Files::Tables::XmlColumn.new(
                  xml_data: xml_data,
                  header: datum[:header],
                  key: datum[:key],
                  identifier: identifier,
                  options: ExcelDataServices::V4::Files::Tables::Options.new(options: datum.except(:header, :key))
                )
              end
            else
              []
            end
          end

          def headers
            @headers ||= xml_columns.map(&:header)
          end

          def identifiers
            @identifiers ||= xml_data.identifiers
          end

          private

          def context
            @context ||= schema_data[:xml_data].presence || { path: [], schema: {} }
          end
        end
      end
    end
  end
end
