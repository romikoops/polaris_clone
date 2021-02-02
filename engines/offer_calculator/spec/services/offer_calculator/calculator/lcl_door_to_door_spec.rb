# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Calculator do
  let(:load_type) { "cargo_item" }
  let(:truck_type) { "default" }
  let(:cargo_classes) { ["lcl"] }
  let(:source) { FactoryBot.create(:application) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      load_type: load_type,
      destination_hub: nil,
      origin_hub: nil,
      destination_nexus: nil,
      origin_nexus: nil,
      desired_start_date: Time.zone.today + 4.days,
      user: user,
      trucking: {
        pre_carriage: {
          address_id: pickup_address.id,
          truck_type: truck_type
        },
        on_carriage: {
          address_id: delivery_address.id,
          truck_type: truck_type
        }
      },
      organization: organization)
  end
  let(:cargo_items_attributes) do
    [
      {
        "payload_in_kg" => 120,
        "total_volume" => 0,
        "total_weight" => 0,
        "width" => 120,
        "length" => 80,
        "height" => 120,
        "quantity" => 1,
        "cargo_item_type_id" => pallet.id,
        "dangerous_goods" => false,
        "stackable" => true
      }
    ]
  end
  let(:params) do
    FactoryBot.build(:journey_request_params,
      pickup_truck_type: truck_type,
      delivery_address: delivery_address,
      delivery_truck_type: truck_type,
      pickup_address: pickup_address,
      direction: "export",
      load_type: load_type,
      selected_day: 4.days.from_now.beginning_of_day.to_s,
      aggregated_cargo_attributes: [],
      cargo_item_type_id: pallet.id,
      cargo_items_attributes: cargo_items_attributes)
  end
  let(:creator) { FactoryBot.create(:users_client, organization: organization) }
  let(:service) {
    described_class.new(
      params: params,
      client: user,
      creator: creator,
      source: source
    ).perform
  }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:carta_double) { double("Carta::Api") }
  let(:result_set) { service.result_sets.order(:created_at).last }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:carta_double) { double("Carta::Api") }

  include_context "complete_route_with_trucking"

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:companies_membership, member: user)
    FactoryBot.create(:organizations_scope, target: organization, content: {closed_quotation_tool: true})
    allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
    allow(Carta::Api).to receive(:new).and_return(carta_double)
    allow(carta_double).to receive(:suggest).with(query: origin_hub.hub_code).and_return(origin)
    allow(carta_double).to receive(:suggest).with(query: destination_hub.hub_code).and_return(destination)
  end

  describe ".perform" do
    let(:results) { result_set.results }

    context "with single trucking Availability" do
      it "perform a booking calculation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "with single trucking Availability and multiple cargo units" do
      let(:cargo_items_attributes) do
        [
          {
            "payload_in_kg" => 120,
            "total_volume" => 0,
            "total_weight" => 0,
            "width" => 120,
            "length" => 80,
            "height" => 120,
            "quantity" => 1,
            "cargo_item_type_id" => pallet.id,
            "dangerous_goods" => false,
            "stackable" => true
          }
        ] * 2
      end

      it "perform a booking calculation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "with multiple trucking Availability" do
      before do
        cargo_classes.each do |cargo_class|
          FactoryBot.create(:trucking_with_unit_rates,
            :with_fees,
            hub: origin_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: trucking_tenant_vehicle_2,
            location: pickup_trucking_location)
          FactoryBot.create(:trucking_with_unit_rates,
            :with_fees,
            hub: destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: trucking_tenant_vehicle_2,
            location: delivery_trucking_location,
            carriage: "on")
        end
      end

      let(:trucking_tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "trucking_2") }
      let(:desired_tenant_vehicle_combos) do
        [
          [tenant_vehicle.id, tenant_vehicle.id, tenant_vehicle.id],
          [tenant_vehicle.id, tenant_vehicle.id, trucking_tenant_vehicle_2.id],
          [trucking_tenant_vehicle_2.id, tenant_vehicle.id, tenant_vehicle.id],
          [trucking_tenant_vehicle_2.id, tenant_vehicle.id, trucking_tenant_vehicle_2.id]
        ]
      end

      it "perform a booking calculation" do
        aggregate_failures do
          expect(results.length).to eq(4)
        end
      end
    end

    context "with parallel routes" do
      before do
        cargo_classes.each do |cargo_class|
          FactoryBot.create(:trucking_with_unit_rates,
            :with_fees,
            hub: itinerary_2.origin_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: tenant_vehicle_2,
            location: pickup_trucking_location)
          FactoryBot.create(:trucking_with_unit_rates,
            :with_fees,
            hub: itinerary_2.destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: tenant_vehicle_2,
            location: delivery_trucking_location,
            carriage: "on")
          FactoryBot.create(:pricings_pricing,
            load_type: load_type,
            cargo_class: cargo_class,
            organization: organization,
            itinerary: itinerary_2,
            tenant_vehicle: tenant_vehicle_2,
            fee_attrs: {rate: 250, rate_basis: :per_unit_rate_basis, min: nil})
          %w[import export].map do |direction|
            FactoryBot.create(:legacy_local_charge,
              direction: direction,
              hub: direction == "export" ? itinerary_2.origin_hub : itinerary_2.destination_hub,
              load_type: cargo_class,
              organization: organization,
              tenant_vehicle: tenant_vehicle_2)
          end
        end
      end

      let!(:itinerary_2) { FactoryBot.create(:default_itinerary, organization: organization) }
      let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "trucking_2") }
      let(:desired_tenant_vehicle_combos) do
        [
          [tenant_vehicle.id, tenant_vehicle.id, tenant_vehicle.id, itinerary.id],
          [tenant_vehicle_2.id, tenant_vehicle_2.id, tenant_vehicle_2.id, itinerary_2.id]
        ]
      end

      it "perform a booking calculation" do
        aggregate_failures do
          expect(results.length).to eq(2)
        end
      end
    end
  end
end
