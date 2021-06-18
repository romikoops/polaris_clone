# frozen_string_literal: true

require "rails_helper"

module Wheelhouse
  RSpec.describe ValidationService, type: :service do
    include_context "complete_route_with_trucking"

    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:cargo_units) do
      [
        FactoryBot.build(:journey_cargo_unit,
          id: SecureRandom.uuid,
          weight_value: 120,
          width_value: 1.20,
          length_value: 0.80,
          height_value: 1.20,
          quantity: 1)
      ]
    end
    let(:scope_content) { {} }
    let(:query) do
      FactoryBot.build(:journey_query,
        client: user,
        organization: organization,
        load_type: load_type == "cargo_item" ? "lcl" : "fcl")
    end
    let(:request) do
      FactoryBot.build(:offer_calculator_request,
        organization: organization,
        params: request_params,
        query: query,
        client: user)
    end
    let(:request_params) do
      FactoryBot.build(:journey_request_params,
        origin_hub: origin_hub,
        load_type: load_type,
        destination_hub: destination_hub,
        client: user)
    end
    let(:origin) { { nexus_id: origin_hub.nexus_id } }
    let(:destination) { { nexus_id: destination_hub.nexus_id } }
    let(:routing) { { origin: origin, destination: destination } }
    let(:load_type) { "cargo_item" }
    let(:cargo_classes) { ["lcl"] }
    let(:final) { false }
    let(:validator) do
      described_class.new(
        request: request,
        final: final
      )
    end
    let(:group) do
      FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
        FactoryBot.create(:groups_membership, group: tapped_group, member: user)
      end
    end
    let(:result) do
      validator.validate
      validator.errors
    end

    before do
      Organizations::Organization.current_id = organization.id
      allow(request).to receive(:cargo_units).and_return(cargo_units)
      allow(validator).to receive(:routing).and_return(routing)
    end

    describe ".perform" do
      before do
        organization.scope.update(content: scope_content)
      end

      context "when port to port complete request (no pricings)" do
        before do
          allow(validator).to receive(:pricings).and_return(Pricings::Pricing.none)
        end

        let(:expected_error_codes) do
          [4008]
        end

        it "returns an array of one error" do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context "when port to port (no routing)" do
        let(:expected_error_codes) do
          [4016]
        end
        let(:routing) { { origin: nil, destination: nil } }
        let(:final) { true }

        it "returns an array of one error" do
          aggregate_failures do
            expect(result.map(&:code)).to match_array(expected_error_codes)
          end
        end
      end

      context "with dedicated pricings" do
        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary, group: group)
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)
        end

        context "when port to port complete request ( group pricings)" do
          let(:expected_error_codes) do
            [4009]
          end
          let(:scope_content) { { dedicated_pricings_only: true } }

          it "returns an no errors" do
            aggregate_failures do
              expect(result).to be_empty
            end
          end
        end
      end

      context "with pricings" do
        before do
          FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary)
          FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)
        end

        context "when port to port complete request (no group pricings)" do
          let(:expected_error_codes) do
            [4009]
          end
          let(:scope_content) { { dedicated_pricings_only: true } }

          it "returns an array of one error" do
            aggregate_failures do
              expect(result.map(&:code)).to match_array(expected_error_codes)
            end
          end
        end

        context "when port to port complete request (invalid cargo)" do
          let(:cargo_units) do
            [
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                weight_value: 120,
                width_value: 1.20,
                length_value: 0.80,
                height_value: 120.0,
                volume_value: 115.2,
                quantity: 1)
            ]
          end
          let(:expected_error_codes) do
            [4002, 4005]
          end

          it "returns an array of one error" do
            aggregate_failures do
              expect(result.map(&:code).uniq).to match_array(expected_error_codes)
            end
          end
        end

        context "when port to port complete request (invalid fcl cargo)" do
          let(:cargo_units) do
            [
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                weight_value: 999_999,
                cargo_class: "fcl_20",
                quantity: 1)
            ]
          end
          let(:load_type) { "container" }
          let(:cargo_classes) { %w[fcl_20] }
          let(:expected_error_codes) { [4001] }

          before do
            FactoryBot.create(:legacy_max_dimensions_bundle,
              cargo_class: "fcl_20",
              organization: organization,
              payload_in_kg: 30_000)
          end

          it "returns an array of one error" do
            aggregate_failures do
              expect(result.map(&:code)).to match_array(expected_error_codes)
            end
          end
        end

        context "when port to port complete request (valid fcl cargo & other mot mdbs)" do
          let(:cargo_units) do
            [
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                weight_value: 29_999,
                cargo_class: "fcl_20",
                quantity: 1)
            ]
          end
          let(:load_type) { "container" }

          before do
            FactoryBot.create(:legacy_max_dimensions_bundle,
              cargo_class: "fcl_20",
              organization: organization,
              payload_in_kg: 30_000)
            FactoryBot.create(:legacy_max_dimensions_bundle,
              cargo_class: "fcl_20",
              mode_of_transport: "air",
              organization: organization,
              payload_in_kg: 10_000)
          end

          it "returns an array of one error" do
            aggregate_failures do
              expect(result.map(&:code)).to be_empty
            end
          end
        end

        context "when door to port (invalid lcl on trucking)" do
          let(:cargo_units) do
            [
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                weight_value: 120,
                width_value: 1.20,
                length_value: 0.80,
                height_value: 1.20,
                quantity: 1)
            ]
          end
          let(:expected_error_codes) do
            [4001]
          end

          let(:origin) { pickup_address }
          let(:routing) { { origin: { latitude: origin.latitude, longitude: origin.longitude }, destination: destination } }

          before do
            FactoryBot.create(:legacy_max_dimensions_bundle,
              cargo_class: "lcl",
              organization: organization, payload_in_kg: 100,
              mode_of_transport: "truck_carriage")
            allow(request).to receive(:pre_carriage?).and_return(true)
            Geocoder::Lookup::Test.add_stub([origin.latitude, origin.longitude], [
              "address_components" => [{ "types" => ["premise"] }],
              "address" => origin.geocoded_address,
              "city" => origin.city,
              "country" => origin.country.name,
              "country_code" => origin.country.code,
              "postal_code" => origin.zip_code
            ])
          end

          it "returns an array of one error" do
            aggregate_failures do
              expect(result.map(&:code)).to match_array(expected_error_codes)
            end
          end
        end

        context "when door to port (invalid fcl on trucking)" do
          let(:cargo_units) do
            [
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                weight_value: 50_000,
                cargo_class: "fcl_20",
                quantity: 1)
            ]
          end
          let(:load_type) { "container" }
          let(:cargo_classes) { %w[fcl_20] }
          let(:expected_error_codes) do
            [4001]
          end
          let(:routing) { { origin: { latitude: pickup_address.latitude, longitude: pickup_address.longitude }, destination: destination } }

          before do
            FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: "fcl_20",
                                                             organization: organization, payload_in_kg: 80_000)
            FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: "fcl_20", organization: organization,
                                                             payload_in_kg: 30_000, mode_of_transport: "truck_carriage")
            allow(request).to receive(:pre_carriage?).and_return(true)
            Geocoder::Lookup::Test.add_stub([pickup_address.latitude, pickup_address.longitude], [
              "address_components" => [{ "types" => ["premise"] }],
              "address" => pickup_address.geocoded_address,
              "city" => pickup_address.city,
              "country" => pickup_address.country.name,
              "country_code" => pickup_address.country.code,
              "postal_code" => pickup_address.zip_code
            ])
          end

          it "returns an array of one error" do
            aggregate_failures do
              expect(result.map(&:code)).to match_array(expected_error_codes)
            end
          end
        end

        context "when port to door (invalid aggregate on trucking)" do
          before do
            Geocoder::Lookup::Test.add_stub([origin.latitude, origin.longitude], [
              "address_components" => [{ "types" => ["premise"] }],
              "address" => origin.geocoded_address,
              "city" => origin.city,
              "country" => origin.country.name,
              "country_code" => origin.country.code,
              "postal_code" => origin.zip_code
            ])
            allow(request).to receive(:pre_carriage?).and_return(true)
            FactoryBot.create(:legacy_max_dimensions_bundle,
              aggregate: true,
              organization: organization,
              mode_of_transport: "truck_carriage",
              payload_in_kg: 500)
          end

          let(:cargo_units) do
            [
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                quantity: 1,
                width_value: 1,
                length_value: 1,
                height_value: 1,
                weight_value: 1.2),
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                quantity: 1,
                width_value: 1,
                length_value: 1,
                height_value: 1,
                weight_value: 500)
            ]
          end

          let(:origin) { pickup_address }
          let(:routing) { { origin: { latitude: origin.latitude, longitude: origin.longitude }, destination: destination } }

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

        context "when door to port (valid on trucking, and on the other mots)" do
          let(:cargo_units) do
            [
              FactoryBot.build(:journey_cargo_unit,
                id: SecureRandom.uuid,
                weight_value: 120,
                width_value: 1.20,
                length_value: 0.80,
                height_value: 1.20,
                quantity: 1)
            ]
          end

          let(:origin) { pickup_address }
          let(:routing) { { origin: { latitude: origin.latitude, longitude: origin.longitude }, destination: destination } }

          before do
            FactoryBot.create(:legacy_max_dimensions_bundle, cargo_class: "lcl", organization: organization,
                                                             payload_in_kg: 150, mode_of_transport: "truck_carriage")

            Geocoder::Lookup::Test.add_stub([origin.latitude, origin.longitude], [
              "address_components" => [{ "types" => ["premise"] }],
              "address" => origin.geocoded_address,
              "city" => origin.city,
              "country" => origin.country.name,
              "country_code" => origin.country.code,
              "postal_code" => origin.zip_code
            ])
          end

          it "returns no errors" do
            aggregate_failures do
              expect(result).to be_empty
            end
          end
        end
      end
    end
  end
end
