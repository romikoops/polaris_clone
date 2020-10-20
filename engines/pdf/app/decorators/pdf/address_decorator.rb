# frozen_string_literal: true

module Pdf
  class AddressDecorator < ApplicationDecorator
    delegate_all

    def address_lines
      [address_line_1, address_line_1, address_line_2].compact.join(" ")
    end

    def street_info
      [street, street_number].compact.join(" ")
    end

    def city_info
      [zip_code, city, country&.name].compact.join(", ")
    end
  end
end
