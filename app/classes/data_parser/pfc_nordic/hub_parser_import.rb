module DataParser
  module PfcNordic
    class HubParserImport < DataParser::BaseParser
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
            type: "hubs",
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

        # def name_without_service_level(str)
        #   if str.include?('(Economy)')
        #     name = str.split(' (').first
        #     return name
        #   elsif str.include?(' - Express 2xWeekly')
        #     name = str.split(' - ').first
        #     return name
        #   elsif str.include?(' - Express')
        #     name = str.split(' - ').first
        #     return name
        #   elsif str.include?('(')
        #       name = str.split(' (').first
        #       return name
        #   else
        #     return str
        #   end
        # end

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
      
        def row_to_hash(row_index, country)
          {
            port:     @sheet.cell("B", row_index),
            routing:     @sheet.cell("G", row_index),
            country:  country
          }
        end

        def parse_hubs
          row_hashes = []
          @sheet.each_with_index do |_row, i|
            row_index = i + 1
            # byebug
            # "Hafen" is unique anchor that differentiates the data
            # of the individual countries.
            puts @sheet.cell("B", row_index)
            next unless @sheet.cell("B", row_index) == "NAME"
            
            country = get_country(row_index)
            
      
            # Look one row after the current one for actual data rows.
            # Stop iterating when no valid float value for the "Rate" column is found.
            row_index += 1
            row_hash = row_to_hash(row_index, country)
            while !row_hash[:port].nil?
              name, service_level = name_and_service_level(row_hash[:port])
              row_hash[:port] = name.strip
              row_hash[:service_level] = service_level
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
end
