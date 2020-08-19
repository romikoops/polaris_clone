# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Validations::ContainerValidationService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization, mode_of_transport: "ocean") }
  let(:result) do
    described_class.errors(
      modes_of_transport: modes_of_transport,
      cargo: cargo,
      itinerary_ids: itinerary_ids,
      tenant_vehicle_ids: tenant_vehicle_ids,
      final: final
    )
  end
  let(:final) { false }
  let(:itinerary_ids) { [itinerary.id] }
  let(:tenant_vehicle_ids) { [tenant_vehicle.id] }
  let(:modes_of_transport) { ["ocean"] }
  let(:cargo) { FactoryBot.build(:cargo_cargo, organization: organization, units: cargos) }

  before do
    Organizations::Organization.current_id = organization.id
  end

  context "with max dimensions" do
    before do
      FactoryBot.create(:legacy_max_dimensions_bundle,
        organization: organization,
        mode_of_transport: "ocean",
        payload_in_kg: 10_000,
        cargo_class: "fcl_20")
    end

    context "when the object is complete and valid" do
      let(:cargos) do
        [FactoryBot.build(:fcl_20_unit,
          organization: organization,
          id: SecureRandom.uuid,
          quantity: 1,
          weight_value: 120)]
      end
      let(:tenant_vehicle_ids) { nil }

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "when the object is incomplete and valid" do
      let(:cargos) do
        [FactoryBot.build(:fcl_20_unit,
          organization: organization,
          id: SecureRandom.uuid,
          quantity: 1,
          weight_value: 0)]
      end
      let(:tenant_vehicle_ids) { nil }

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "when the object is incomplete and valid (final)" do
      let(:cargos) do
        [FactoryBot.build(:fcl_20_unit,
          organization: organization,
          id: SecureRandom.uuid,
          quantity: 1,
          weight_value: 0)]
      end
      let(:tenant_vehicle_ids) { nil }
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
      let(:cargos) do
        [FactoryBot.build(:fcl_20_unit,
          organization: organization,
          id: SecureRandom.uuid,
          quantity: 1,
          weight_value: -1.0)]
      end
      let(:tenant_vehicle_ids) { nil }
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
      let(:cargos) do
        [FactoryBot.build(:fcl_20_unit,
          organization: organization,
          id: SecureRandom.uuid,
          quantity: 1,
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
      let(:cargos) do
        [FactoryBot.build(:fcl_20_unit,
          organization: organization,
          id: SecureRandom.uuid,
          quantity: 0,
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
      let(:cargos) do
        [
          FactoryBot.build(:fcl_20_unit,
            organization: organization,
            id: SecureRandom.uuid,
            quantity: 1,
            width_value: 1,
            length_value: 1,
            height_value: 1,
            weight_value: 120),
          FactoryBot.build(:fcl_20_unit,
            organization: organization,
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
      let(:cargos) do
        [FactoryBot.build(:fcl_20_unit,
          organization: organization,
          id: SecureRandom.uuid,
          quantity: 1,
          weight_value: 120)]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end
  end
end
