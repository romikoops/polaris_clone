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
  let(:cargo_items_attributes) { [cargo_item_attributes] }
  let(:cargo_item_attributes) do
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
  let(:service) do
    described_class.new(
      params: params,
      client: user,
      creator: creator,
      source: source
    ).perform
  end
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:result_set) { service.result_sets.order(:created_at).last }

  include_context "complete_route_with_trucking"

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:companies_membership, client: user)
    organization.scope.update(content: { closed_quotation_tool: true })
    allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin)
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(destination)
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
          cargo_item_attributes
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
            tenant_vehicle: trucking_tenant_vehicle2,
            location: pickup_trucking_location)
          FactoryBot.create(:trucking_with_unit_rates,
            :with_fees,
            hub: destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: trucking_tenant_vehicle2,
            location: delivery_trucking_location,
            carriage: "on")
        end
        FactoryBot.create(:routing_carrier, name: trucking_tenant_vehicle2.carrier.name, code: trucking_tenant_vehicle2.carrier.code)
      end

      let(:trucking_tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, name: "trucking2") }
      let(:desired_tenant_vehicle_combos) do
        [
          [tenant_vehicle.id, tenant_vehicle.id, tenant_vehicle.id],
          [tenant_vehicle.id, tenant_vehicle.id, trucking_tenant_vehicle2.id],
          [trucking_tenant_vehicle2.id, tenant_vehicle.id, tenant_vehicle.id],
          [trucking_tenant_vehicle2.id, tenant_vehicle.id, trucking_tenant_vehicle2.id]
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
        allow(Carta::Client).to receive(:suggest).with(query: itinerary2.origin_hub.nexus.locode).and_return(origin2)
        allow(Carta::Client).to receive(:suggest).with(query: itinerary2.destination_hub.nexus.locode).and_return(destination2)
        cargo_classes.each do |cargo_class|
          FactoryBot.create(:trucking_with_unit_rates,
            :with_fees,
            hub: itinerary2.origin_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: tenant_vehicle2,
            location: pickup_trucking_location)
          FactoryBot.create(:trucking_with_unit_rates,
            :with_fees,
            hub: itinerary2.destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: tenant_vehicle2,
            location: delivery_trucking_location,
            carriage: "on")
          FactoryBot.create(:pricings_pricing,
            load_type: load_type,
            cargo_class: cargo_class,
            organization: organization,
            itinerary: itinerary2,
            tenant_vehicle: tenant_vehicle2,
            fee_attrs: { rate: 250, rate_basis: :per_unit_rate_basis, min: nil })
          %w[import export].map do |direction|
            FactoryBot.create(:legacy_local_charge,
              direction: direction,
              hub: direction == "export" ? itinerary2.origin_hub : itinerary2.destination_hub,
              load_type: cargo_class,
              organization: organization,
              tenant_vehicle: tenant_vehicle2)
          end
        end
        FactoryBot.create(:routing_carrier, name: tenant_vehicle2.carrier.name, code: tenant_vehicle2.carrier.code)
      end

      let!(:itinerary2) { FactoryBot.create(:legacy_itinerary, organization: organization) }
      let(:tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, name: "trucking2") }
      let(:desired_tenant_vehicle_combos) do
        [
          [tenant_vehicle.id, tenant_vehicle.id, tenant_vehicle.id, itinerary.id],
          [tenant_vehicle2.id, tenant_vehicle2.id, tenant_vehicle2.id, itinerary2.id]
        ]
      end
      let(:origin2) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
      let(:destination2) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }

      it "perform a booking calculation" do
        aggregate_failures do
          expect(results.length).to eq(2)
        end
      end
    end
  end
end
