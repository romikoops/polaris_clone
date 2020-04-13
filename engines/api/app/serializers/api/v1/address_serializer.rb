# frozen_string_literal: true

module Api
  module V1
    class AddressSerializer < Api::ApplicationSerializer
      attributes %i[longitude latitude geocoded_address street city]
      attribute :country do |address|
        address.country&.name
      end

      attribute :postal_code, &:zip_code
      attribute :name, &:geocoded_address
    end
  end
end
