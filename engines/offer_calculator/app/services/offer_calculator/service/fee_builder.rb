# frozen_string_literal: true

module OfferCalculator
  module Service
    class FeeBuilder < Base
      def self.fees(request:, associations:, schedules:)
        new(request: request).perform(associations: associations, schedules: schedules)
      end

      def perform(associations:, schedules:)
        associations.flat_map do |_section, association|
          OfferCalculator::Service::Charges::Generator.results(
            association: association,
            request: request,
            schedules: schedules
          )
        end
      end
    end
  end
end
