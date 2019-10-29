# frozen_string_literal: true

module Api
  class ItineraryPortSerializer < ActiveModel::Serializer
    type 'ports'
    attributes :id, :origin_id, :origin, :destination_id, :destination

    def origin_id
      first_stop.hub.nexus_id
    end

    def origin
      first_stop.hub.nexus.name
    end

    def destination_id
      last_stop.hub.nexus_id
    end

    def destination
      last_stop.hub.nexus.name
    end

    private

    def first_stop
      scope[:stops_by_itinerary][object.id].first
    end

    def last_stop
      scope[:stops_by_itinerary][object.id].last
    end
  end
end
