module DataParser
  module PfcNordic
    class HubParserExport < DataParser::BaseParser
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
      
        def row_to_hash(row_index, country)
          port = @sheet.cell("B", row_index)
          code =  @sheet.cell("D", row_index)
          puts port
          {
            port:     port ? port.strip : '',
            code:     code ? code.strip : nil,
            country:  country
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
              if @sheet.cell("A", row_index) == "x"
                row_index += 1
                row_hash = row_to_hash(row_index, country)
              end
              name, service_level = name_and_service_level(row_hash[:port])
              row_hash[:port] = name
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
