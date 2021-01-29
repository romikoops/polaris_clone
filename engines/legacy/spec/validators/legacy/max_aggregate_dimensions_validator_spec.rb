# frozen_string_literal: true

require "rails_helper"

RSpec.describe Legacy::MaxAggregateDimensionsValidator do
  let(:user) { FactoryBot.create(:users_client) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: user.organization) }
  let(:tenant_vehicle) { FactoryBot.build(:legacy_tenant_vehicle, organization: user.organization) }
  let(:trip) { FactoryBot.build(:legacy_trip, tenant_vehicle: tenant_vehicle) }
  let(:valid_cargos) { [FactoryBot.build(:legacy_cargo_item, quantity: 10)] }
  let(:agg_cargo) { FactoryBot.build(:legacy_aggregated_cargo) }
  let(:invalid_cargos) { [FactoryBot.build(:legacy_cargo_item, quantity: 10_000)] }
  let(:args) do
    {
      trip_id: trip.id,
      itinerary_id: itinerary.id,
      organization: user.organization,
      user: user
    }
  end

  context "with max dimensions" do
    before do
      FactoryBot.create(:legacy_max_dimensions_bundle, organization: user.organization)
      FactoryBot.create(:legacy_max_dimensions_bundle, :aggregated, organization: user.organization)
    end

    it "passes validation" do
      expect(Legacy::Shipment.new(args.merge(cargo_items: valid_cargos))).to be_valid
    end

    it "passes validation with agg cargo" do
      expect(Legacy::Shipment.new(args.except(:trip_id, :itinerary_id).merge(aggregated_cargo: agg_cargo))).to be_valid
    end

    it "passes validation without a trip set" do
      expect(Legacy::Shipment.new(args.except(:trip_id, :itinerary_id).merge(cargo_items: valid_cargos))).to be_valid
    end

    it "passes validation with agg cargo without a trip set" do
      expect(Legacy::Shipment.new(args.merge(aggregated_cargo: agg_cargo))).to be_valid
    end

    it "fails validation with an above 21770kg" do
      expect(Legacy::Shipment.new(args.merge(cargo_items: invalid_cargos))).to be_invalid
    end
  end

  context "without max dimensions" do
    it "passes validation" do
      expect(Legacy::Shipment.new(args.merge(cargo_items: valid_cargos))).to be_valid
    end
  end
end
