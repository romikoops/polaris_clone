# frozen_string_literal: true

module Legacy
  class ItinerarySerializer < ActiveModel::Serializer
    attributes %i[id mode_of_transport name stops]

    def stops
      object.stops.as_json(
        include: {
          hub: {
            include: {
              nexus: { only: %i[id name] },
              address: { only: %i[longitude latitude geocoded_address] }
            },
            only: %i[id name]
          }
        },
        only: %i[id index]
      )
    end
  end
end
