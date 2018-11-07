# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :addresses
  has_many :nexuses
  Geoplace = Struct.new(:name, :code)
  # Class Methods
  def self.geo_find_by_name(name)
    geocoder_results = Geocoder.search(country: name)
    return nil if geocoder_results.empty?

    code = geocoder_results.first.data["address_components"].first["short_name"]
    find_by(code: code)
  end

  def self.geo_find_by_names(names)
    geocoder_results = Geocoder.search(country: names)

    geocoder_results.map do |geo|
      Geoplace.new(
        geo.data["address_components"].first["long_name"],
        geo.data["address_components"].first["short_name"]
      )
    end
  end
end
