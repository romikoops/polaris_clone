# frozen_string_literal: true

FactoryBot.define do
  factory :measurements_request, class: "OfferCalculator::Service::Measurements::Request" do
    skip_create
    request { FactoryBot.create(:offer_calculator_request) }
    scope { {} }

    initialize_with do
      OfferCalculator::Service::Measurements::Request.new(
        request: request,
        scope: scope,
        object: object
      )
    end
  end
end
