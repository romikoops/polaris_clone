module Carta
  class Result < Struct.new(
    :id,
    :type,
    :address,
    :latitude,
    :longitude,
    :street,
    :street_number,
    :postal_code,
    :locality,
    :administrative_area,
    :country,
    keyword_init: true
  )
    def postal_code
      @postal_code ||= geocoded_data.zipcode
    end

    def geocoded_data
      @geocoded_data ||= Legacy::Address.new(
        latitude: latitude, longitude: longitude
      ).reverse_geocode
    end

    def city
      nexus? ? address : locality
    end

    def nexus?
      type == "locode"
    end
  end
end
