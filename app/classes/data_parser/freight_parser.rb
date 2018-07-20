module DataParser
  class FreightParser < DataParser::BaseParser
    attr_reader :path, :user, :port_object

    def post_initialize(args)
      @sheet = @xlsx.sheet(@xlsx.sheets.first)
    end

    def perform
      parse_hubs
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
          country:  country
        }
      end

      def parse_hubs
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
          row_hash = row_to_hash(row_index, country)
          while !row_hash[:code].nil?
            row_hashes << row_hash
            row_index += 1
            row_hash = row_to_hash(row_index, country)
          end
          
        end
        awesome_print row_hashes
        row_hashes
      end
  end
end
