# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Generator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:query) { FactoryBot.create(:journey_query, client: user, organization: organization, cargo_count: 0) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, organization: organization, query: query) }
  let(:period) { Range.new(Time.zone.today, 2.weeks.from_now.to_date) }
  let(:schedules) { [OfferCalculator::Schedule.from_trip(FactoryBot.create(:legacy_trip, closing_date: Time.zone.today, start_date: Time.zone.today, end_date: 2.weeks.from_now.to_date))] }
  let(:charges) { described_class.results(request: request, association: relation, schedules: schedules) }
  let(:relation) { Pricings::Pricing.where(organization: organization) }
  let(:built_fees) do
    [
      instance_double(OfferCalculator::Service::Charges::Charge,
        context_id: "aaaa",
        percentage?: false,
        value: Money.new(10_000, "USD"))
    ]
  end
  let(:calculated_charges) do
    [
      instance_double(OfferCalculator::Service::Calculators::Charge, value: Money.new(10_000, "USD"))
    ]
  end

  before do
    builder_double = instance_double(OfferCalculator::Service::Charges::Builder, perform: built_fees)
    allow(OfferCalculator::Service::Charges::Builder).to receive(:new).with(relation: relation, request: request, period: period).and_return(builder_double)
    validity_double = instance_double(OfferCalculator::ValidityService, period: period)
    allow(OfferCalculator::ValidityService).to receive(:new).and_return(validity_double)
    calculator_double = instance_double(OfferCalculator::Service::Charges::Calculator, perform: calculated_charges)
    allow(OfferCalculator::Service::Charges::Calculator).to receive(:new).with(charges: built_fees).and_return(calculator_double)
    Organizations.current_id = organization.id
  end

  describe "#charges" do
    it "calls the classes with the correct arguments resulting in a Charge" do
      expect(charges.length).to eq(1)
    end
  end
end
