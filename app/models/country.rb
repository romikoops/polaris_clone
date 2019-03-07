# frozen_string_literal: true

class Country < Legacy::Country
  has_many :addresses
  has_many :nexuses
  Geoplace = Struct.new(:name, :code)

  def self.geo_find_by_name(name)
    geocoder_results = Geocoder.search(country: name)
    return nil if geocoder_results.empty?

    code = geocoder_results.first.data['address_components'].first['short_name']
    find_by(code: code)
  end

  def self.geo_find_by_names(names)
    geocoder_results = Geocoder.search(country: names)

    geocoder_results.map do |geo|
      Geoplace.new(
        geo.data['address_components'].first['long_name'],
        geo.data['address_components'].first['short_name']
      )
    end
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  code       :string
#  flag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
