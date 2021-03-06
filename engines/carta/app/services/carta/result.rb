# frozen_string_literal: true

module Carta
  Result = Struct.new(
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
    :function,
    keyword_init: true
  ) do
    def city
      nexus? ? address : locality
    end

    def nexus?
      type == "locode"
    end
  end
end
