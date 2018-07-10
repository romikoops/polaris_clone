module DataParser
  module PfcNordic
    class RateParserExport < DataParser::BaseParser
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
            port:     @sheet.cell("B", row_index),
            code:     @sheet.cell("D", row_index),
            rate:     @sheet.cell("F", row_index),
            currency: @sheet.cell("I", row_index),
            min:  @sheet.cell("J", row_index),
            basis:    @sheet.cell("K", row_index),
            notes:    @sheet.cell("M", row_index),
            country:  country
          }
        end

        def hash_to_rate(hash)
          rate = { 
            rate_basis: 'PER_WM',
            rate: hash[:rate],
            currency: hash[:currency],
            
          }
          if hash[:basis] == 'FRT'
            rate[:min] = hash[:min] * hash[:rate]
          else
            rate[:min] = hash[:min]
          end
          {
            rate: rate,
            data: {
              code: hash[:code],
              port: hash[:port],
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
            next unless @sheet.cell("B", row_index) == "Hafen"
      
            country = get_country(row_index)
            
      
            # Look one row after the current one for actual data rows.
            # Stop iterating when no valid float value for the "Rate" column is found.
            row_index += 1
            row_hash = hash_to_rate(row_to_hash(row_index, country))
            
            while !row_hash[:data][:code].nil?
              row_hashes << row_hash
              row_index += 1
              row_hash = hash_to_rate(row_to_hash(row_index, country))
            end
            
          end
          awesome_print row_hashes
          row_hashes
        end
    end
  end
end
