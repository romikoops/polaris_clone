# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Xml < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[xml_columns xml_data].freeze

          def xml_data
            @xml_data ||= ExcelDataServices::V4::Files::XmlContext.new(xml_data: xml.dig(*context[:path]), schema: context[:schema])
          end

          def xml_columns
            @xml_columns ||= schema_data[:xml_columns].map do |datum|
              ExcelDataServices::V4::Files::Tables::XmlColumn.new(
                xml_data: xml_data,
                header: datum.delete(:header),
                key: datum.delete(:key),
                options: ExcelDataServices::V4::Files::Tables::Options.new(options: datum)
              )
            end
          end

          private

          def context
            @context ||= schema_data[:xml_data]
          end
        end
      end
    end
  end
end
