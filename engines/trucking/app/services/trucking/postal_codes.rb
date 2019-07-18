# frozen_string_literal: true

module Trucking
  class PostalCodes
    DATA_DIR = File.expand_path('../../../data/', __dir__)

    def self.for(country_code:)
      return nil unless File.exist?(File.join(DATA_DIR, "#{country_code}.txt"))

      File.read(File.join(DATA_DIR, "#{country_code}.txt")).split
    end

  end
end
