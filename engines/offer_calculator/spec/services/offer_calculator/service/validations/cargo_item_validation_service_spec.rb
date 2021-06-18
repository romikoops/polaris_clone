# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Validations::CargoItemValidationService do
  before do
    FactoryBot.create(:legacy_max_dimensions_bundle,
      organization: organization,
      mode_of_transport: "ocean",
      volume: 1000)
    Organizations::Organization.current_id = organization.id
    allow(request).to receive(:cargo_units).and_return(cargo_units)
  end

  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
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
  let(:modes_of_transport) { ["ocean"] }
  let(:final) { false }
  let(:itinerary_ids) { [itinerary.id] }
  let(:tenant_vehicle_ids) { [tenant_vehicle.id] }
  let(:pricings) do
    Pricings::Pricing.all
  end
  let(:cargo_units) do
    [FactoryBot.build(:journey_cargo_unit,
      width_value: 1.20,
      length_value: 0.80,
      height_value: 1.40,
      weight_value: 500,
      quantity: 1)]
  end

  describe ".perform" do
    before do
      FactoryBot.create(:pricings_pricing,
        organization: organization,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle)
    end

    context "when the object is complete and valid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 1,
          width_value: 1.2,
          length_value: 1.2,
          height_value: 1.2,
          weight_value: 120)]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "when the object is complete and valid aggregated lcl" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          :aggregate_lcl,
          weight_value: 120)]
      end

      it "passes validation" do
        expect(result).to be_empty
      end
    end

    context "when the object is complete and valid except for trucking" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          quantity: 1,
          width_value: 1.2,
          length_value: 1.2,
          height_value: 1.2,
          weight_value: 120)]
      end
      let(:expected_help_text) do
        ["Chargeable Weight exceeds the limit of 50 kg"]
      end
      let(:expected_error_codes) do
        [4005]
      end

      before do
        allow(request).to receive(:pre_carriage?).and_return(true)
        FactoryBot.create(:legacy_max_dimensions_bundle,
          aggregate: false,
          mode_of_transport: "truck_carriage",
          organization: organization,
          chargeable_weight: 50)
      end

      it "returns an empty array", :aggregate_failures do
        expect(result.map(&:message)).to match_array(expected_help_text)
        expect(result.map(&:code).uniq).to match_array(expected_error_codes)
      end
    end

    context "when the object is incomplete and valid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 1,
          width_value: 1.2,
          length_value: 0,
          height_value: 0,
          weight_value: 0)]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "when the object is incomplete and valid (final)" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 0,
          width_value: 1.2,
          length_value: 0,
          height_value: 0,
          weight_value: 0)]
      end
      let(:final) { true }
      let(:expected_help_text) do
        ["Length is required.",
          "Quantity is required.",
          "Height is required.",
          "Weight is required."]
      end
      let(:expected_error_codes) do
        [4010, 4011, 4013, 4017]
      end

      it "returns an an array of missing values" do
        aggregate_failures do
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context "when the object is invalid (negative values)" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 1,
          width_value: -1.2,
          length_value: -1.0,
          height_value: -1.0,
          weight_value: -1.0)]
      end
      let(:tenant_vehicle_ids) { nil }
      let(:expected_help_text) do
        ["Length must be positive.",
          "Height must be positive.",
          "Width must be positive.",
          "Volume must be positive.",
          "Chargeable Weight must be positive.",
          "Weight must be positive."]
      end
      let(:expected_error_codes) do
        [4015]
      end

      it "returns an an array of missing values" do
        aggregate_failures do
          expect(result.length).to eq(9)
          expect(result.map(&:message).uniq).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context "when the object is complete and all attrs are invalid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 1,
          width_value: 12,
          length_value: 12,
          height_value: 12,
          weight_value: 12_000)]
      end
      let(:expected_help_text) do
        ["Width exceeds the limit of 5 m",
          "Length exceeds the limit of 5 m",
          "Height exceeds the limit of 5 m",
          "Weight exceeds the limit of 10000 kg",
          "Volume exceeds the limit of 1000 m3",
          "Chargeable Weight exceeds the limit of 10000 kg"]
      end
      let(:expected_error_codes) do
        [4001, 4002, 4003, 4004, 4005, 4018]
      end

      it "returns an array of 5 errors" do
        aggregate_failures do
          expect(result.length).to eq(6)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array(expected_error_codes)
        end
      end
    end

    context "when the object is incomplete and invalid" do
      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 1,
          width_value: 12,
          length_value: 0,
          height_value: 0,
          weight_value: 0)]
      end
      let(:expected_help_text) { ["Width exceeds the limit of 5 m"] }

      it "returns an array of one error" do
        aggregate_failures do
          expect(result.length).to eq(1)
          expect(result.map(&:message)).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array([4003])
        end
      end
    end

    context "when the cargos are valid but aggregate chargeable weight invalid" do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
          aggregate: true,
          organization: organization,
          mode_of_transport: "ocean",
          tenant_vehicle: tenant_vehicle,
          chargeable_weight: 500)
      end

      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          quantity: 1,
          width_value: 1,
          length_value: 1,
          height_value: 1,
          weight_value: 120),
          FactoryBot.create(:journey_cargo_unit,
            quantity: 1,
            width_value: 1,
            length_value: 1,
            height_value: 1,
            weight_value: 400)]
      end
      let(:expected_help_text) do
        [
          "Aggregate Chargeable Weight exceeds the limit of 500 kg"
        ]
      end

      it "returns an array of errors for each input when aggregate fails validation" do
        aggregate_failures do
          expect(result.length).to eq(8)
          expect(result.map(&:message).uniq).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array([4006])
        end
      end
    end

    context "when the cargos are valid but aggregate weight invalid" do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
          aggregate: true,
          organization: organization,
          mode_of_transport: "ocean",
          tenant_vehicle: tenant_vehicle,
          payload_in_kg: 500)
      end

      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 1,
          width_value: 1,
          length_value: 1,
          height_value: 1,
          weight_value: 1.2),
          FactoryBot.build(:journey_cargo_unit,
            quantity: 1,
            width_value: 1,
            length_value: 1,
            height_value: 1,
            weight_value: 500)]
      end
      let(:expected_help_text) do
        [
          "Aggregate Weight exceeds the limit of 500 kg"
        ]
      end

      it "returns an array of errors for each input when aggregate fails validation" do
        aggregate_failures do
          expect(result.length).to eq(2)
          expect(result.map(&:message).uniq).to match_array(expected_help_text)
          expect(result.map(&:code).uniq).to match_array([4007])
        end
      end
    end

    context "when the cargos are valid but volume invalid" do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
          aggregate: true,
          organization: organization,
          mode_of_transport: "ocean",
          tenant_vehicle: tenant_vehicle,
          chargeable_weight: 1_000_000,
          volume: 15)
      end

      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          quantity: 1,
          width_value: 5,
          length_value: 2,
          height_value: 1,
          weight_value: 1.2),
          FactoryBot.create(:journey_cargo_unit,
            quantity: 1,
            width_value: 5,
            length_value: 2,
            height_value: 1,
            weight_value: 1.2)]
      end
      let(:expected_result) do
        cargo_units.flat_map do |unit|
          %i[width length height].map do |dimension|
            OfferCalculator::Service::Validations::Error.new(
              id: unit.id,
              message: "Aggregate Volume exceeds the limit of 15 m3",
              attribute: dimension,
              limit: "15 m3",
              section: "cargo_item",
              code: 4019
            )
          end
        end
      end

      it "returns an array of errors for each input when aggregate fails validation" do
        expect(result).to match_array(expected_result)
      end
    end

    context "when the cargos are invalid for one of two mots" do
      before do
        FactoryBot.create(:legacy_max_dimensions_bundle,
          organization: organization,
          mode_of_transport: "air",
          tenant_vehicle: tenant_vehicle,
          payload_in_kg: 500)
        FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
        FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)
      end

      let(:air_itinerary) do
        FactoryBot.create(:legacy_itinerary, organization: organization, mode_of_transport: "air")
      end
      let(:itinerary_ids) { [itinerary, air_itinerary].map(&:id) }
      let(:modes_of_transport) { %w[ocean air] }

      let(:cargo_units) do
        [FactoryBot.build(:journey_cargo_unit,
          quantity: 1,
          width_value: 1,
          length_value: 1,
          height_value: 1,
          weight_value: 120),
          FactoryBot.build(:journey_cargo_unit,
            quantity: 1,
            width_value: 1,
            length_value: 1,
            height_value: 1,
            weight_value: 500)]
      end

      it "returns an array of errors for each input when aggregate fails validation" do
        aggregate_failures do
          expect(result.length).to eq(0)
        end
      end
    end
  end
end
