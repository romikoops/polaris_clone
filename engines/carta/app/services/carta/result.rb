# frozen_string_literal: true
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

    def city
      nexus? ? address : locality
    end

    def nexus?
      type == "locode"
    end
  end
end
