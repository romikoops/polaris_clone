# frozen_string_literal: true

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
          "FXT" => "Felixstowe",
          "WVN" => "Wilhelmshaven"
        }
      end

      def _stats
        {
          type:    "rates",
          ports:   {
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
          ports:   [],
          nexuses: []
        }
      end

      def split_and_capitalise(str)
        return str if str.upcase != str
        str_array = str.split(" ")
        if str_array.length > 1
          return str_array.map { |s| s.capitalize! || s }.join(" ")
        else
          str_array = ["unknown"] if str_array.first.nil?
          capitalised = str_array.first.capitalize!
          if capitalised.nil?
            return str
          else
            return capitalised
          end
        end
      end

      def get_hub_name(str)
        if @input_language && @input_language != "en"
          to_translate = "city: #{str}"
          translation = Translator::GoogleTranslator.new(origin_language: @input_language, target_language: "en", text: to_translate).perform
          result = translation.text
          string = result.gsub("city: ", "")
          puts string
        else
          string = str
        end
        string.split(", ").map { |s| split_and_capitalise(s) }
      end

      def row_to_hash(row)
        
        {
          ports_of_loading: row[:origins],
          carrier:          row[:carrier],
          rates:            {
            fcl_20:    row[:fcl_20_rate],
            fcl_40:    row[:fcl_40_rate],
            fcl_40_hq: row[:fcl_40_hq_rate]
          },
          currency:         row[:currency],
          fees:             {
            thc:  row[:thc],
            isps: row[:isps],
            ebs:  row[:ebs]
          },
          notes:            row[:transshipments],
          country:          row[:country],
          destination:      row[:destination],
          effective_date:   row[:effective_date],
          expiration_date:  row[:expiration_date],
          transittime:      row[:transit_time]
        }
      end

      def service_level_from_transshipment(str)
        if str
          service_level = str.downcase.include?("via") ? str[/\(.*?\)/] : str
          service_level.downcase.tr(" ", "_")
        else
          "standard"
        end
      end

      def determine_routes(hash, port_name)
        itineraries = {}
        return nil unless hash[:ports_of_loading]
        destination = destination_port_name(port_name)
        origins = hash[:ports_of_loading].delete(' ').split("/").map do |hub_code|
          hub_name = determine_hub_from_abbreviation(hub_code)
          itineraries[hub_code] = { 
            name: "#{hub_name} - #{destination}",
            origin: hub_name,
            destination: destination
          }
        end
        itineraries
      end

      def destination_port_name(port_name)
        if port_name.downcase.end_with?(" port")
          return port_name
        else
          return "#{port_name} Port"
        end
      end

      def determine_hub_from_abbreviation(abv)
        case abv
        when "RTM"
          "Rotterdam Port"
        when "BRV"
          "Bremerhaven Port"
        when "ANR"
          "Antwerp Port"
        when "HAM"
          "Hamburg Port"
        when "WVN"
          "Wilhelmshaven Port"
        when "FXT"
          "Felixstowe Port"
        end
      end

      def return_country_for_origin

      end

      def hub_abbreviations_from_country(_country)
        case abv
        when "DE"
          %w(HAM BRV WVN)
        when "NL"
          ["RTM"]
        when "BE"
          ["ANR"]
        end
      end

      def fees_with_slashes(existing_fees, fee_code, str)
        if str.include?("/")
          rates = str.split("/")
          %w(DE NL BE).each_with_index do |code, ind|
            hub_abvs = hub_abbreviations_from_country(code)
            hub_abvs.each do |hub_code|
              existing_fees[hub_code][:fees] = {} unless existing_fees[hub_code][:fees]
              existing_fees[hub_code][:fees][fee_code] = rates[ind] || 0
            end
          end
        else
          %w(DE NL BE).each_with_index do |code, _ind|
            hub_abvs = hub_abbreviations_from_country(code)
            hub_abvs.each do |hub_code|
              existing_fees[hub_code][:fees] = {} unless existing_fees[hub_code][:fees]
              existing_fees[hub_code][:fees][fee_code] = str
            end
          end
        end
      end

      def hash_to_rate(hash)
        rates = []
        %i(fcl_20 fcl_40 fcl_40_hq).each do |sym|
          rates << {
            rate_basis: "PER_CONTAINER",
            rate:       hash[:rates][sym],
            currency:   hash[:currency],
            code:       "BAS",
            cargo_class:  sym.to_s
          }
        end
        names_obj = extract_names(hash[:destination])
        # if names_obj[:name] == 'Cabinda'
        #   byebug
        # end
        {
          rate: rates,
          data: {
            itineraries:       determine_routes(hash, names_obj[:name]),
            code:              hash[:code],
            port:              names_obj[:name],
            alternative_names: names_obj[:alternative_names],
            country:           hash[:country],
            carrier:           hash[:carrier],
            load_type:         load_type,
            mot:               @hub_type,
            service_level:     service_level_from_transshipment(hash[:transshipment])
          }
        }
      end

      def validate_row(row)
        check1 = begin
                     Float(row[:fcl_20_rate])
                   rescue StandardError
                     nil
                   end
        check2 = begin
                     Float(row[:fcl_40_rate])
                   rescue StandardError
                     nil
                   end
        check3 = begin
                     Float(row[:fcl_40_hq_rate])
                   rescue StandardError
                     nil
                   end
        check4 = row[:country]
        check5 = row[:origins]

        [check1, check2, check3, check4, check5].none?(nil)
      end

      def parse_alternative_names(str)
        if str.include?('/')
          return str.split('/').map{|char| char.delete("(").delete(")")}
        elsif str.include?(',')
          return str.split(',').map{|char| char.delete("(").delete(")")}
        else
          return str.delete("(").delete(")")
        end
      end

      def extract_names(str)
        new_str = str.gsub("(Free-out)", "")
        alternative_names_str = new_str[/\(.*?\)/]
        new_str.sub!(/\(.*?\)/, "")
        if !alternative_names_str && new_str.include?(',')
          names = new_str.split(',')
          new_str = names.shift()
          alternative_names = names
        elsif alternative_names_str
          alternative_names = parse_alternative_names(alternative_names_str)
        end
        if alternative_names
         
          alt_name = alternative_names
        end
        if new_str.end_with?("  ")
          new_str.slice!(-2, 2)
        elsif new_str.end_with?(" ")
          new_str.slice!(-1)
        end
        if new_str.starts_with?("  ")
          new_str.slice!(0,1)
        elsif new_str.starts_with?(" ")
          new_str.slice!(0)
        end
        if new_str.include?("(")
          byebug
        end
        { name: new_str, alternative_names: alt_name }
      end

      def parse_sheet_rows(sheet)
        sheet.parse(
          country:         "Country",
          destination:     "Destination",
          transshipment:   "Transshipment",
          effective_date:  "Valid from",
          expiration_date: "Expiry Date",
          carrier:         "Carrier",
          fcl_20_rate:     "20'DC",
          fcl_40_rate:     "40'DC",
          fcl_40_hq_rate:  "40'HC",
          # thc:              "THC(D/NL/B)",
          # isps:             "ISPS",
          currency:        "Cur.",
          # ebs:              "EBS/TEU",
          origins:         "POL"
          # transit_time:     "Transittime"
        )
      end

      def parse_rates
        row_hashes = []
        @sheets.each do |sheet|
          @sheet = @xlsx.sheet(sheet)
          @sheet_rows = parse_sheet_rows(@sheet)
          @sheet_rows.each_with_index do |row, _i|
            next unless validate_row(row)
            @row = row

            row_hash = row_to_hash(@row)

            converted_hash = hash_to_rate(row_hash)
            row_hashes << converted_hash
            awesome_print converted_hash
          end
          
        end
        row_hashes
    end
    end
  end
end
