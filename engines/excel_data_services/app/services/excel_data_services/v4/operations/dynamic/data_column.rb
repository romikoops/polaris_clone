# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      module Dynamic
        class DataColumn
          STANDARD_OCEAN_COLUMNS = %w[20dc 40dc 40hq].freeze
          TWENTY_FT_CLASSES = %w[fcl_20].freeze
          FORTY_FT_CLASSES =  %w[fcl_40 fcl_40_hq].freeze
          PRIMARY_CODE_PLACEHOLDER = "PRIMARY_FREIGHT_CODE"

          def initialize(header:, frame:)
            @header = header
            @frame = frame
          end

          def fee?
            %i[fee month].include?(category)
          end

          def fee_code
            @fee_code ||= STANDARD_OCEAN_COLUMNS.include?(raw_fee_code) ? PRIMARY_CODE_PLACEHOLDER : header_values.last.downcase
          end

          def data
            @data ||= case category
                      when :note, :month
                        extracted_row_frame
                      else
                        extracted_row_frame.inner_join(cargo_classes, on: { "row" => "row", "sheet_name" => "sheet_name" })
            end
          end

          def row_extractors
            @row_extractors ||= header_frame.to_a.flat_map do |frame_row|
              RowDataExtractor.new(row: frame_row, column: self)
            end
          end

          def extracted_row_frame
            @extracted_row_frame ||= Rover::DataFrame.new(row_extractors.flat_map(&:row_data))
          end

          def cargo_classes
            @cargo_classes ||= Rover::DataFrame.new(
              frame[frame["cargo_class"].missing][%w[row sheet_name]].to_a.uniq
                .product(column_cargo_classes.map { |cargo_class| { "cargo_class" => cargo_class } })
                .map { |row, cargo_class| row.merge(cargo_class) }
            ).concat(frame[!frame["cargo_class"].missing][%w[cargo_class row sheet_name]])
          end

          def category
            @category ||= case raw_category
                          when /month/
                            :month
                          when /int/
                            :internal
                          when /note/
                            :note
                          else
                            :fee
            end
          end

          def current?
            raw_category.include?("curr_")
          end

          attr_reader :header, :frame

          private

          def column_cargo_classes
            @column_cargo_classes ||= if STANDARD_OCEAN_COLUMNS.include?(raw_fee_code)
              raw_fee_code == "20dc" ? TWENTY_FT_CLASSES : FORTY_FT_CLASSES
            elsif raw_cargo_class
              raw_cargo_class == "20" ? TWENTY_FT_CLASSES : FORTY_FT_CLASSES
            else
              TWENTY_FT_CLASSES + FORTY_FT_CLASSES
            end
          end

          def raw_category
            @raw_category ||= header_values.first
          end

          def raw_fee_code
            @raw_fee_code ||= header_values.last
          end

          def raw_cargo_class
            @raw_cargo_class ||= header_values.second_to_last
          end

          def header_frame
            @header_frame ||= frame[values_to_extract]
          end

          def header_values
            header.gsub(/\ADynamic\([a-zA-Z0-9-)]{1,}:/, "").split("/")
          end

          def values_to_extract
            [header, "row", "sheet_name", "effective_date", "expiration_date"]
          end
        end
      end
    end
  end
end
