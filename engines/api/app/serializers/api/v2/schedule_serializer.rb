# frozen_string_literal: true

module Api
  module V2
    class ScheduleSerializer < Api::ApplicationSerializer
      attributes %i[id vessel_no voyage_code estimated_arrival_time estimated_departure_time closing_date]
    end
  end
end
