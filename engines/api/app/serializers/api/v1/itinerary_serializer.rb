# frozen_string_literal: true

module Api
  module V1
    class ItinerarySerializer < ActiveModel::Serializer
      type 'Itinerary'
      attributes %i[id mode_of_transport name]
      has_many :stops, each_serializer: StopSerializer
    end
  end
end
