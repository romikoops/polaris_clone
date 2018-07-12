module DataParser
  module PfcNordic
    class SheetParserImport < DataParser::BaseParser
      attr_reader :path, :user, :port_object, :counterpart_hub_name, :load_type, :hub_type, :input_language

      def post_initialize(args)
        @sheet = @xlsx.sheet(@xlsx.sheets.first)
        @counterpart_hub_name = args[:counterpart_hub_name]
        @load_type = args[:load_type]
        @cargo_class = args[:cargo_class]
        @hub_type = args[:hub_type]
        @input_language = args[:input_language]
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
          @sheet.row(row_index - 1).compact.first
        end

        def split_and_capitalise(str)
          if str.upcase != str
            return str
          end
          str_array = str.split(' ')
          if str_array.length > 1
            return str_array.map{|s| s.capitalize! || s}.join(' ')
          else
            if str_array.first.nil?
              str_array = ['unknown']
            end
            capitalised = str_array.first.capitalize!
            if capitalised.nil?
              return str
            else
              return capitalised
            end
          end
        end

        def get_hub_name(str)
          
          if @input_language && @input_language != 'en'
            translation = Translator::GoogleTranslator.new(origin_language: @input_language, target_language: 'en', text: str).perform
            string = translation.text
            puts string
          else
            string = str
          end
          string.split(', ').map{|s| split_and_capitalise(s)}
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
            return name.strip, 'economy'
          elsif str.include?(' - Express')
            name = str.split(' - ').first
            return name.strip, 'express'
          elsif str.include?('(')
              name = str.split(' (').first
              return name.strip, 'standard'
          else
            return str, 'standard'
          end
        end

        def hash_to_rate(hash)
          rates = []
          main_rate = { 
            rate_basis: 'PER_WM',
            rate: hash[:rate],
            currency: hash[:currency],
            code: 'BAS'
          }
          if hash[:basis] == 'FRT'
            main_rate[:min] = hash[:min] * hash[:rate]
          else
            main_rate[:min] = hash[:min]
          end
          rates << main_rate

          if hash[:port]
            name, service_level = name_and_service_level(hash[:port])
            port_name, country_name = get_hub_name("#{name}, #{hash[:country]}")
            
          else
            port_name = "unknown"
            country_name = hash[:country]
          end

          {
            rate: rates,
            data: {
              code: hash[:code],
              routing: hash[:routing],
              port: port_name,
              country: country_name,
              counterpart_hub_name: @counterpart_hub_name,
              load_type: load_type,
              mot: @hub_type,
              service_level: service_level
            }
          }
        end

        def parse_rates
          row_hashes = []
          @sheet.each_with_index do |_row, i|
            row_index = i + 1
      
            # "Hafen" is unique anchor that differentiates the data
            # of the individual countries.
            puts @sheet.cell("B", row_index)
            next unless @sheet.cell("B", row_index) == "NAME"
      
            country = get_country(row_index)
            
            
            # Look one row after the current one for actual data rows.
            # Stop iterating when no valid float value for the "Rate" column is found.
            row_index += 1
            row_hash = row_to_hash(row_index, country)
            
            while !row_hash[:port].nil? && !row_hash[:rate].nil?
              if @sheet.cell("A", row_index) == "x" || row_hash[:port].nil?
                row_index += 1
                row_hash = row_to_hash(row_index, country)
              end
              converted_hash = hash_to_rate(row_hash)
              row_hashes << converted_hash
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
