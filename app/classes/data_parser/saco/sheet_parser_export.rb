module DataParser
  module Saco
    class SheetParserExport < DataParser::BaseParser
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
        def ports_of_loading
          {
            "BRV" => "Bremerhaven",
            "HAM" => "Hamburg",
            "RTM" => "Rotterdam",
            "ANR" => "Antwerp",
            "FXT" => "Felixstowe"
          }
        end
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
            to_translate = "city: #{str}"
            translation = Translator::GoogleTranslator.new(origin_language: @input_language, target_language: 'en', text: to_translate).perform
            result = translation.text
            # if str.downcase.include?('chattan')
            #   byebug
            # end
            string = result.gsub('city: ', '')
            puts string
          else
            string = str
          end
          string.split(', ').map{|s| split_and_capitalise(s)}
        end
      
        def row_to_hash
          {
            ports_of_loading:     @row[:origins],
            carrier:     @row[:carrier],
            rates:     {
              fcl_20: @row[:fcl_20_rate],
              fcl_40: @row[:fcl_40_rate],
              fcl_40_hq: @row[:fcl_40_hq_rate],
            },
            currency: @row[:currency],
            fees:      {
              thc: @row[:thc],
              isps: @row[:isps],
              ebs: @row[:ebs]
            },
            notes:    @row[:transshipments],
            country:  @row[:country],
            port_of_destination: @row[:destination],
            effective_date: @row[:effective_date],
            expiration_date: @row[:expiration_date],
            transittime: @row[:transit_time]
          }
        end

        def service_level_from_transshipment(str)
          if str.downcase.include?('via')
            service_level = str[/\(.*?\)/]
          else
            service_level = str
          end
          return service_level.downcase.gsub(' ', '_')
        end

       def determine_routes(hash)
        
        itineraries = {}
        origins = hash[:ports_of_loading].split('/').map do |hub_code|
          
          hub_name = determine_hub_from_abbreviation(hub_code)
          itineraries[hub_code] = {name: "#{destination_port_name} - #{hub_name}", fees: {}, rates: {} }
        end
        itineraries
       end
      
       def destination_port_name
        port_name = @row[:destination]
        if port_name.downcase.end_with?(' port')
          return port_name
        else
          return "#{port_name} Port"
       end

      def determine_hub_from_abbreviation(abv)
        case abv
        when 'RTM'
          return 'Rotterdam Port'  
        when 'BRV'
          return 'Bremerhaven Port'  
        when 'ANR'
          return 'Antwerp Port'  
        when 'HAM'
          return 'Hamburg Port'  
        when 'WVN'
          return 'Wilhelmhaven Port'  
        when 'FXT'
          return 'Felixstowe Port'  
      end

      def hub_abbreviations_from_country(country)
        case abv
        when 'DE'
          return ['HAM', 'BRV', 'WVN']
        when 'NL'
          return ['RTM']
        when 'BE'
          return ['ANR'] 
      end

      def fees_with_slashes(existing_fees, fee_code, str)
        if str.include?('/')
          rates = str.split('/')
          ['DE', 'NL', 'BE'].each_with_index do |code, ind|
            hub_abvs = hub_abbreviations_from_country(code)
            hub_abvs.each do |hub_code|
              existing_fees[hub_code][:fees] = {} unless existing_fees[hub_code][:fees]
              existing_fees[hub_code][:fees][fee_code] = rates[ind] || 0
            end
          end
        else
          ['DE', 'NL', 'BE'].each_with_index do |code, ind|
            hub_abvs = hub_abbreviations_from_country(code)
            hub_abvs.each do |hub_code|
              existing_fees[hub_code][:fees] = {} unless existing_fees[hub_code][:fees]
              existing_fees[hub_code][:fees][fee_code] = str
            end
          end
        end
      end

        def hash_to_rate(hash)
          itineraries_hash = determine_routes(hash)
          rates = []
          main_rate = { 
            rate_basis: 'PER_WM',
            rate: hash[:rate],
            currency: hash[:currency],
            code: 'BAS'
          }
          rates << main_rate
          if hash[:basis] == 'FRT'
            main_rate[:min] = hash[:min] * hash[:rate]
          else
            main_rate[:min] = hash[:min]
          end

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
              port: port_name,
              country: country_name,
              counterpart_hub_name: @counterpart_hub_name,
              load_type: load_type,
              mot: @hub_type,
              service_level: service_level
            }
          }
        end
        
        def validate_row(row)
          check1 = Float(row[:fcl_20_rate]) rescue nil
          check2 = Float(row[:fcl_40_rate]) rescue nil
          check3 = Float(row[:fcl_40_hq_rate]) rescue nil
          check4 = row[:country] || nil
         return ![check1, check2, check3, check4].include?(nil)

        end

        def extract_names(str)
          new_str = str.gsub('(Free-out)','')
          alternative_names = new_str[/\(.*?\)/]
          if alternative_names
            new_str.gsub!(/\(.*?\)/, '')
            alt_name = alternative_names.gsub('(','').gsub(')','')
          end
          if new_str.end_with?('  ')
            new_str.slice!(-2)
          elsif new_str.end_with?('  ')
            new_str.slice!(-1)
          end
          return {name: new_str, alternative_name: alt_name}
        end
          


        def parse_sheet_rows(sheet)
          sheet.parse(
            country:         "Country",
            destination:     "Destination",
            transshipment:   "Transshipment",
            effective_date:  "Valid from",
            expiration_date: "Expiry Date",
            carrier:          "Carrier",
            fcl_20_rate:     "20'DC",
            fcl_40_rate:     "40'DC",
            fcl_40_hq_rate:  "40'HC",
            thc:              "THC(D/NL/B)",
            isps:             "ISPS",
            currency:         "Cur.",
            ebs:              "EBS/TEU",
            origins:          "POL",
            transit_time:     "Transittime"
          )
        end

       

        def parse_rates
          row_hashes = []
          @sheets.each do |sheet|
            @sheet = @xlsx.sheet(sheet)
            @sheet_rows = parse_sheet_rows(@sheet)
            @sheet_rows.each_with_index do |_row, i|
              row_index = i + 1
              
              # "Hafen" is unique anchor that differentiates the data
              # of the individual countries.
              next unless validate_row(row)
              @row = row
              
              row_hash = row_to_hash
              
              while !row_hash[:destination].nil?
                if row_hash[:port].nil?
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
