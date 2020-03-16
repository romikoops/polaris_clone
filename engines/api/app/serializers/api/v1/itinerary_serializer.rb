# frozen_string_literal: true

module Api
  module V1
    class ItinerarySerializer < Api::ApplicationSerializer
      set_type 'Itinerary'
      attributes %i[id mode_of_transport name]
      has_many :stops, serializer: StopSerializer, if: proc { |_, params|
        params[:includes]&.include?('stops')
      }
    end
  end
end
