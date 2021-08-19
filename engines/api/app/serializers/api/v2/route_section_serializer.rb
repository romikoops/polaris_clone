# frozen_string_literal: true

module Api
  module V2
    class RouteSectionSerializer < Api::ApplicationSerializer
      attributes %i[id
        service
        carrier
        carrier_logo
        mode_of_transport
        transshipment
        transit_time
        origin
        destination]
    end
  end
end
