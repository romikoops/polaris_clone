# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class ResultSetBuilder
        attr_reader :request, :offers

        delegate :result_set, to: :request

        def self.results_set(request:, offers:)
          new(request: request, offers: offers).results_set
        end

        def initialize(request:, offers:)
          @request = request
          @offers = offers
        end

        def results_set
          offers.each do |offer|
            ResultBuilder.result(request: request, offer: offer)
          end
          result_set
        end
      end
    end
  end
end
