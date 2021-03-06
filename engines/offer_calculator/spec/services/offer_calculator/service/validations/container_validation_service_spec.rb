# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Validations::ContainerValidationService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:itinerary) do
    FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization, mode_of_transport: "ocean")
  end
  let(:result) do
    described_class.errors(
      request: request,
      pricings: pricings,
      final: final
    )
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:final) { false }
  let(:itinerary_ids) { [itinerary.id] }
  let(:tenant_vehicle_ids) { [tenant_vehicle.id] }
  let(:modes_of_transport) { ["ocean"] }
  let(:cargo_units) do
    [FactoryBot.build(:journey_cargo_unit,
      cargo_class: "fcl_20",
      weight_value: 500,
      quantity: 1)]
  end
  let(:pricings) do
    Pricings::Pricing.all
  end

  before do
    allow(request).to receive(:cargo_units).and_return(cargo_units)
    allow(request).to receive(:load_type).and_return("container")
    Organizations::Organization.current_id = organization.id
  end

  context "with max dimensions" do
    before do
      FactoryBot.create(:fcl_20_pricing,
        organization: organization,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:legacy_max_dimensions_bundle,
        organization: organization,
        mode_of_transport: "ocean",
        payload_in_kg: 10_000,
        cargo_class: "fcl_20")
    end

    context "when the object is complete and valid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 1,
          cargo_class: "fcl_20",
          weight_value: 120)]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "when pricings relation is empty" do
      let(:pricings) { Pricings::Pricing.none }
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 1,
          cargo_class: "fcl_20",
          weight_value: 120)]
      end

      it "returns uses of the same load type to fill in for the defaults, returning an empty array" do
        expect(result).to eq([])
      end
    end

    context "when the object is incomplete and valid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 1,
          cargo_class: "fcl_20",
          weight_value: 0)]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "when the object is incomplete and valid (final)" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 1,
          cargo_class: "fcl_20",
          weight_value: 0)]
      end
      let(:final) { true }
      let(:expected_help_text) do
        ["Weight is required."]
      end
      let(:expected_error_codes) do
        [4010]
      end

      it "returns an an arrya of missing values" do
        aggregate_failures do
          expect(result.length).to eq(1)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context "when the object is invalid (negative values)" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 1,
          cargo_class: "fcl_20",
          weight_value: -1.0)]
      end
      let(:expected_help_text) do
        ["Weight must be positive."]
      end
      let(:expected_error_codes) do
        [4015]
      end

      it "returns an an arrya of missing values" do
        aggregate_failures do
          expect(result.length).to eq(1)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context "when the object is complete and all attrs are invalid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 1,
          cargo_class: "fcl_20",
          weight_value: 12_000)]
      end
      let(:modes_of_transport) { ["ocean"] }
      let(:expected_help_text) do
        ["Weight exceeds the limit of 10000 kg"]
      end
      let(:expected_error_codes) do
        [4001]
      end

      it "returns an array of 5 errors" do
        aggregate_failures do
          expect(result.length).to eq(1)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context "when the object is incomplete and invalid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 0,
          cargo_class: "fcl_20",
          weight_value: 999_999)]
      end
      let(:modes_of_transport) { ["ocean"] }
      let(:expected_help_text) { ["Weight exceeds the limit of 10000 kg"] }

      it "returns an array of one error" do
        aggregate_failures do
          expect(result.length).to eq(1)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array([4001])
        end
      end
    end

    context "when the cargos are invalid for one of two mots" do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: organization,
          mode_of_transport: "rail",
          cargo_class: "fcl_20",
          tenant_vehicle: tenant_vehicle,
          payload_in_kg: 500)
      end

      let(:modes_of_transport) { %w[air ocean] }
      let(:cargo_units) do
        [
          FactoryBot.build(:journey_cargo_unit,
            id: SecureRandom.uuid,
            quantity: 1,
            width_value: 1,
            length_value: 1,
            height_value: 1,
            weight_value: 120),
          FactoryBot.build(:journey_cargo_unit,
            id: SecureRandom.uuid,
            quantity: 1,
            width_value: 1,
            length_value: 1,
            height_value: 1,
            weight_value: 500)
        ]
      end

      it "returns an array of errors for each input when aggregate fails validation" do
        aggregate_failures do
          expect(result.length).to eq(0)
        end
      end
    end
  end

  context "without max dimensions" do
    context "when the object is complete and valid" do
      before do
        FactoryBot.create(:fcl_20_pricing,
          organization: organization,
          itinerary: itinerary,
          tenant_vehicle: tenant_vehicle)
      end

      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 0,
          cargo_class: "fcl_20",
          weight_value: 120)]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end
  end

  context "without cargo units" do
    before do
      FactoryBot.create(:fcl_20_pricing,
        organization: organization,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle)
    end

    let(:cargo_units) { [] }

    it "returns an empty array" do
      expect(result).to be_empty
    end
  end
end
