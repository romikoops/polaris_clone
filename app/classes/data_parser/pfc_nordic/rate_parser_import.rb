module DataParser
  module PfcNordic
    class RateParserImport < DataParser::BaseParser
      attr_reader :path, :user, :port_object, :counterpart_hub_name, :load_type, :mot

      def post_initialize(args)
        @sheet = @xlsx.sheet(@xlsx.sheets.first)
        @counterpart_hub_name = args[:counterpart_hub_name]
        @load_type = args[:load_type]
        @mot = args[:mot]
      end

      def perform
        parse_rates
      end

      private
      
        def _stats
          {
            type: "rates",
            ports: {
              number_updated: 0,
              number_created: 0
            },
            nexuses: {
              number_updated: 0,
              number_created: 0
            }
          }
        end

        def _results
          {
            ports: [],
            nexuses: []
          }
        end

        def get_country(row_index)
          # Look one row above current one for country name.
          @sheet.row(row_index - 1).first
        end
      
        def row_to_hash(row_index, country)
          {
            port:             @sheet.cell("B", row_index),
            rate:             @sheet.cell("D", row_index),
            currency:         @sheet.cell("C", row_index),
            min:              @sheet.cell("E", row_index),
            transit_time:     @sheet.cell("F", row_index),
            routing:          @sheet.cell("G", row_index),
            country:          country
          }
        end

        def name_and_service_level(str)
          if str.include?('(Economy)')
            name = str.split(' (').first
            return name, 'economy'
          elsif str.include?(' - Express')
            name = str.split(' - ').first
            return name, 'express'
          elsif str.include?('(')
              name = str.split(' (').first
              return name, 'standard'
          else
            return str, 'standard'
          end
        end

        def hash_to_rate(hash)
          rate = { 
            rate_basis: 'PER_WM',
            rate: hash[:rate],
            currency: hash[:currency],
            min: hash[:min]  
          }
          
          name, service_level = name_and_service_level(hash[:port])
          
          {
            rate: rate,
            data: {
              transit_time: hash[:transit_time].split(' days').first.to_i,
              port: name,
              service_level: service_level,
              counterpart_hub_name: @counterpart_hub_name,
              load_type: load_type,
              mot: mot
            }
          }
        end

        def parse_rates
          row_hashes = []
          @sheet.each_with_index do |_row, i|
            row_index = i + 1
      
            # "Hafen" is unique anchor that differentiates the data
            # of the individual countries.
            next unless @sheet.cell("B", row_index) == "NAME"
      
            country = get_country(row_index)
            
      
            # Look one row after the current one for actual data rows.
            # Stop iterating when no valid float value for the "Rate" column is found.
            row_index += 1
            row_hash = row_to_hash(row_index, country)
            
            while !row_hash[:port].nil?
              converted_row_hash = hash_to_rate(row_hash)
              row_hashes << converted_row_hash
              row_index += 1
              row_hash = row_to_hash(row_index, country)
            end
            
          end
          awesome_print row_hashes
          row_hashes
        end
    end
  end
end
