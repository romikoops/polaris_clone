module DataParser
  module Schryver
    class FtlParser < DataParser::BaseParser
      attr_reader :path, :user, :port_object, :counterpart_hub_name, :load_type, :hub_type, :input_language

      def post_initialize(args)
        @sheets = @xlsx.sheets
        @counterpart_hub_name = args[:counterpart_hub_name]
        @load_type = args[:load_type]
        @hub_type = args[:hub_type]
        @input_language = args[:input_language]
      end

      def perform
        parse_rates
      end

      private
        def parse_sheet_rows(sheet)
          @sheet_rows = []
          (2..sheet.last_row).each do |line|
            row = sheet.row(line)
            next unless validate_row(row)
            @sheet_rows << {
              zip_code: row[0],
              destination: row[1],
              routing: row[2],
              origin: row[3],
              rates: {
                fcl_20: {
                  under_16_5: row[4],
                  under_26: row[5],
                  under_30: row[6]
                },
                fcl_40: {
                  under_28: row[7],
                  under_30: row[8]
                },
                fcl_40_hq: {
                  under_28: row[7],
                  under_30: row[8]
                }
              }
            }
          end
        end

        def validate_row(row)
          check =  Float(row[0]) rescue nil
          return !check.nil?
        end

        def collate_by_origin_and_destinations
          @collated_rows = {}
          @sheet_rows.each do |row|
            if row[:origin].include?(';')
              cities = row[:origin].split(';')
              row_keys = cities.map{|city| "#{city}-#{row[:zipcode]}"}
            else
              row_keys = ["#{row[:origin]}-#{row[:zipcode]}"]
            end
            row_keys.each do |origin|
              row_key = origin.split(' ').first
              unless @collated_rows[row_key]
                @collated_rows[row_key] = {}
              end
              unless @collated_rows[row_key][row[:destination]]
                @collated_rows[row_key][row[:destination]] = []
              end
              @collated_rows[row_key][row[:destination]] << row
            end
          end
        end

        def determine_highest_price
          @final_rows = {}
          @collated_rows.each do |origin, destinations|
            unless @final_rows[origin]
              @final_rows[origin] = {}
            end
            destinations.each do |destination, rates|
              unless @final_rows[origin][destination]
                @final_rows[origin][destination] = {}
              end
              
              rates.sort do |x,y| 
                total_x = [x[:rates][:fcl_20].values.sum, x[:rates][:fcl_40].values.sum, x[:rates][:fcl_40_hq].values.sum].sum
                total_y = [y[:rates][:fcl_20].values.sum, y[:rates][:fcl_40].values.sum, y[:rates][:fcl_40_hq].values.sum].sum
                total_x <=> total_y
              end
              @final_rows[origin][destination] = rates.last
            end
          end
        end

       

        def parse_rates
          parse_sheet_rows(@xlsx.sheet(@sheets.last))
          collate_by_origin_and_destinations
          determine_highest_price
          byebug
        end
    end
  end
end
