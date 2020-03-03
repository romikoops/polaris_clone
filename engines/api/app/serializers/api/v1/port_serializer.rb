# frozen_string_literal: true

module Api
  module V1
    class PortSerializer < ActiveModel::Serializer
      attributes %i[id name hub_type]
    end
  end
end
