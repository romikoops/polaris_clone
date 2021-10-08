# frozen_string_literal: true

module Api
  module V2
    class ScheduleDecorator < Draper::Decorator
      delegate_all
      decorates_association :result, with: ResultDecorator

      def transit_time
        @transit_time ||= arrival_departure_difference
      end

      private

      def arrival_departure_difference
        (object.destination_arrival.to_date - object.origin_departure.to_date).to_i
      end
    end
  end
end
