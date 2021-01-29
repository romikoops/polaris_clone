# frozen_string_literal: true

require_relative "./basic_setup"
require_relative "./complete_route_with_trucking"

RSpec.shared_context "full_offer" do
  let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
  include_context "offer_calculator_shared_context"
  include_context "complete_route_with_trucking"
  let(:request) { FactoryBot.build(:offer_calculator_request, cargo_trait: cargo_trait, organization: organization) }
  let(:load_type) { "container" }
  let(:cargo_trait) { load_type == "container" ? :fcl : :lcl }
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:calculator_results) do
    (pricings | local_charges | truckings).flat_map do |object|
      FactoryBot.build(:calculators_result_from_raw,
        raw_object: object,
        request: request)
    end
  end
  let(:offer) do
    OfferCalculator::Service::OfferCreators::Offer.new(
      request: request,
      schedules: schedules,
      offer: calculator_results.group_by(&:section)
    )
  end
end
