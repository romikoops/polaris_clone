# frozen_string_literal: true

module Api
  module V2
    class ScheduleSerializer < Api::ApplicationSerializer
      attributes %i[
        id vessel_name vessel_code voyage_code origin destination destination_arrival origin_departure closing_date carrier service mode_of_transport
      ]
    end
  end
end
