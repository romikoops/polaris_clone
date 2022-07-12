# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      class XmlData
        MissingPathError = Class.new(StandardError)
        InvalidPathError = Class.new(StandardError)

        attr_reader :xml, :schema, :path

        def initialize(xml:, path:, schema:)
          @xml = xml
          @schema = schema
          @path = path
          validate_paths!
        end

        def data_for(key:, identifier:)
          return [] unless frame.include?(key)

          frame.filter(identifier_key => identifier)[key].to_a
        end

        def frame
          @frame ||= Rover::DataFrame.new(
            xml_data.flat_map do |datum|
              headers = datum.dig(*header_path) || {}
              charges_extracted_from(datum: datum).map do |row|
                row.merge(headers)
                  .tap { |tapped_row| tapped_row.merge("sheet_name" => tapped_row[identifier_key]) }
              end
            end
          )
        end

        def charges_extracted_from(datum:)
          charges = datum.dig(*body_path)
          charges.is_a?(Array) ? charges : [charges]
        end

        def identifiers
          @identifiers ||= frame[identifier_key].to_a.uniq
        end

        def count_for(identifier:)
          frame.filter(identifier_key => identifier).count
        end

        def identifier_key
          schema[:identifier]
        end

        private

        def xml_data
          xml.dig(*path)
        end

        def header_path
          schema[:header]
        end

        def body_path
          schema[:body]
        end

        def validate_paths!
          raise MissingPathError, "Missing body path: #{body_path}" if body_path.empty?
          raise InvalidPathError, "All paths must be arrays of strings" unless [body_path, header_path].all? { |path| path.is_a?(Array) && path.all?(String) }
        end
      end
    end
  end
end
