# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Calculator do
  let(:load_type) { "cargo_item" }
  let(:cargo_classes) { ["lcl"] }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
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
  let(:query) do
    described_class.new(
      client: user,
      creator: user,
      source: FactoryBot.create(:application),
      params: FactoryBot.build(:journey_request_params,
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
    ).perform
  end

  include_context "complete_route_with_trucking"

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:companies_membership, client: user)
    organization.scope.update(content: { closed_quotation_tool: true })
    allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(
      FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
    )
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
      FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
    )
  end

  describe ".perform" do
    let(:results) { query.results }

    context "with single trucking Availability" do
      it "perform a booking calculation" do
        expect(results.length).to eq(1)
      end
    end

    context "with single trucking Availability and multiple cargo units" do
      let(:cargo_items_attributes) { [cargo_item_attributes] * 2 }

      it "perform a booking calculation" do
        expect(results.length).to eq(1)
      end
    end

    context "with multiple trucking availability" do
      before do
        trucking_tenant_vehicle2 = FactoryBot.create(:legacy_tenant_vehicle, name: "trucking2")
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

      it "perform a booking calculation" do
        expect(results.length).to eq(4)
      end
    end

    context "with parallel routes" do
      before do
        tenant_vehicle2 = FactoryBot.create(:legacy_tenant_vehicle, name: "trucking2")
        itinerary2 = FactoryBot.create(:legacy_itinerary, organization: organization)
        allow(Carta::Client).to receive(:suggest).with(query: itinerary2.origin_hub.nexus.locode).and_return(
          FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
        )
        allow(Carta::Client).to receive(:suggest).with(query: itinerary2.destination_hub.nexus.locode).and_return(
          FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
        )
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

      it "perform a booking calculation" do
        expect(results.length).to eq(2)
      end
    end

    context "when LineItem value is out of range" do
      before do
        FactoryBot.create(:pricings_fee,
          :per_kg,
          pricing: pricings.first,
          rate: 1_000_000,
          charge_category: FactoryBot.build(:baf_charge),
          organization: organization)
      end

      it "perform a booking calculation" do
        expect { query }.to raise_error(OfferCalculator::Errors::OfferBuilder)
      end
    end
  end
end
