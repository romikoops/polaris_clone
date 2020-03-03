# frozen_string_literal: true

module Api
  module V1
    class AddressSerializer < ActiveModel::Serializer
      attributes %i[longitude latitude geocoded_address]
    end
  end
end
