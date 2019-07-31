# frozen_string_literal: true

namespace :locations do
  task locode_geocoding: :environment do
    ::Locations::Name.where.not(locode: nil).where(city: nil, country_code: 'gb').each do |loc|
      lng_lat = loc.point.coordinates
      tmp_address = Address.new(latitude: lng_lat[1], longitude: lng_lat[0]).reverse_geocode
      loc.postal_code = tmp_address.zip_code unless loc.postal_code
      loc.city = tmp_address.city unless loc.city
      country = tmp_address.country
      loc.country = country&.name if !loc.country && country&.code&.downcase == loc.country_code
      loc.save!
    end
  end
end
