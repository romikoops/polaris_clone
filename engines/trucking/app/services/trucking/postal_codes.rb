# frozen_string_literal: true

module Trucking
  class PostalCodes
    DATA_DIR = File.expand_path("../../../data/", __dir__)

    def self.for(country_code:)
      return nil unless File.exist?(File.join(DATA_DIR, "#{country_code}.txt"))

      File.read(File.join(DATA_DIR, "#{country_code}.txt")).split
    end

    def self.country_codes
      Dir.glob("#{DATA_DIR}/*.txt").map do |path|
        path.split("/").last.gsub(".txt", "")
      end
    end

    def self.all
      country_codes.flat_map do |country_code|
        self.for(country_code: country_code).map do |postal_code|
          {"country_code" => country_code.upcase, "postal_code" => postal_code}
        end
      end
    end
  end
end
