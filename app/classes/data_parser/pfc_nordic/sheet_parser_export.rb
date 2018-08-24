# frozen_string_literal: true

module DataParser
  module PfcNordic
    class SheetParserExport < DataParser::BaseParser
      attr_reader :path, :user, :port_object, :counterpart_hub_name, :load_type, :hub_type, :input_language

      def post_initialize(args)
        @sheet = @xlsx.sheet(@xlsx.sheets.first)
        @counterpart_hub_name = args[:counterpart_hub_name]
        @load_type = args[:load_type]
        @hub_type = args[:hub_type]
        @input_language = args[:input_language]
      end

      def perform
        parse_rates
      end

      private

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

      def get_country(row_index)
        # Look one row above current one for country name.
        @sheet.row(row_index - 1).compact.first
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

      def row_to_hash(row_index, country)
        {
          port:     @sheet.cell("B", row_index),
          code:     @sheet.cell("D", row_index),
          rate:     @sheet.cell("F", row_index),
          currency: @sheet.cell("I", row_index),
          min:      @sheet.cell("J", row_index),
          basis:    @sheet.cell("K", row_index),
          notes:    @sheet.cell("M", row_index),
          country:  country
        }
      end

      def name_and_service_level(str)
        if str.include?("(Economy)")
          name = str.split(" (").first
          [name, "economy"]
        elsif str.include?(" - Express")
          name = str.split(" - ").first
          [name, "express"]
        elsif str.include?("(")
          name = str.split(" (").first
          [name, "standard"]
        else
          [str, "standard"]
        end
      end

      def parse_notes_for_rate(notes)
        if notes&.include?("PLUS ONCARRIAGE")
          rate, min = find_money_values(notes)
          rate_currency, rate_value = rate ? rate.split(" ") : "USD 0".split(" ")
          min_currency, min_value = min ? min.split(" ") : "USD 0".split(" ")
          { min: min_value.to_f, rate: rate_value.to_f, currency: rate_currency, code: "XAS", rate_basis: "PER_CBM" }
        else
          false
        end
      end

      def hash_to_rate(hash)
        rates = []
        main_rate = {
          rate_basis: "PER_WM",
          rate:       hash[:rate],
          currency:   hash[:currency],
          code:       "BAS"
        }
        rates << main_rate
        main_rate[:min] = if hash[:basis] == "FRT"
                            hash[:min] * hash[:rate]
                          else
                            hash[:min]
                          end
        note_rate = parse_notes_for_rate(hash[:notes])
        rates << note_rate if note_rate
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
            code:                 hash[:code],
            port:                 port_name,
            country:              country_name,
            counterpart_hub_name: @counterpart_hub_name,
            load_type:            load_type,
            mot:                  @hub_type,
            service_level:        service_level
          }
        }
      end

      def find_money_values(str, values_only=false)
        currencies = %w(USD EUR)
        reg = /((#{currencies.join("|")})\s*(\d+([.,]{1}[\d-]+)?))/m
        str.scan(reg).map { |el| el[values_only ? 2 : 0] } # always strings
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
          row_hash = row_to_hash(row_index, country)

          until row_hash[:code].nil?
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
