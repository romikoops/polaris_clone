# frozen_string_literal: true

module Api
  module V1
    class TripDecorator < Draper::Decorator
      decorates 'Legacy::Trip'

      delegate_all

      def carrier
        tenant_vehicle.carrier&.name || '-'
      end

      def service
        tenant_vehicle.name
      end

      def start
        start_date.strftime('%F')
      end

      def closing
        closing_date.strftime('%F')
      end

      def end
        end_date.strftime('%F')
      end

      def tender_id
        context[:tender_id]
      end
    end
  end
end
