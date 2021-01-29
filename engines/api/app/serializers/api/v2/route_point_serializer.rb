# frozen_string_literal: true

module Api
  module V2
    class RoutePointSerializer < Api::ApplicationSerializer
      attributes %i[id
        latitude
        longitude
        locode
        description
        country]
    end
  end
end
