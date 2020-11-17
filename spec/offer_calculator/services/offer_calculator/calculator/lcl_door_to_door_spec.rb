# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Calculator do
  let(:load_type) { "cargo_item" }
  let(:truck_type) { "default" }
  let(:cargo_classes) { ["lcl"] }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      load_type: load_type,
      destination_hub: nil,
      origin_hub: nil,
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
    ActionController::Parameters.new(
      "shipment" => {
        "id" => shipment.id,
        "direction" => "export",
        "selected_day" => 4.days.from_now.beginning_of_day.to_s,
        "cargo_items_attributes" => cargo_items_attributes,
        "containers_attributes" => [],
        "trucking" => {
          "pre_carriage" => {
            address_id: pickup_address.id,
            truck_type: truck_type
          },
          "on_carriage" => {
            address_id: delivery_address.id,
            truck_type: truck_type
          }
        },
        "origin" => {
          "latitude" => pickup_address.latitude,
          "longitude" => pickup_address.longitude,
          "nexus_name" => origin_hub.nexus.name,
          "country" => origin_hub.nexus.country.code,
          "full_address" => pickup_address.geocoded_address
        },
        "destination" => {
          "latitude" => delivery_address.latitude,
          "longitude" => delivery_address.longitude,
          "nexus_name" => destination_hub.nexus.name,
          "country" => destination_hub.nexus.country.code,
          "full_address" => delivery_address.geocoded_address
        },
        "incoterm" => {},
        "aggregated_cargo_attributes" => nil
      }
    )
  end
  let(:origin_address_params) do
    {
      latitude: pickup_address.latitude,
      longitude: pickup_address.longitude,
      zip_code: pickup_address.zip_code,
      country: pickup_address.country.name,
      geocoded_address: pickup_address.geocoded_address,
      street_number: pickup_address.street_number
    }.with_indifferent_access
  end
  let(:destination_address_params) do
    {
      latitude: delivery_address.latitude,
      longitude: delivery_address.longitude,
      zip_code: delivery_address.zip_code,
      country: delivery_address.country.name,
      geocoded_address: delivery_address.geocoded_address,
      street_number: delivery_address.street_number
    }.with_indifferent_access
  end
  let(:quotation) { Quotations::Quotation.first }
  let(:creator) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:service) { described_class.new(shipment: shipment, params: params, user: user, creator: creator).perform }

  include_context "complete_route_with_trucking"

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope, target: organization, content: {closed_quotation_tool: true})
    allow_any_instance_of(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:address_params).with(:origin).and_return(origin_address_params)
    allow_any_instance_of(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:address_params).with(:destination).and_return(destination_address_params)
    allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
  end

  describe ".perform" do
    context "with single trucking Availability" do
      let!(:legacy_results) { service.detailed_schedules }

      it "perform a booking calculation" do
        aggregate_failures do
          expect(legacy_results.length).to eq(1)
          expect(legacy_results.first.keys).to match_array(%i[quote schedules meta notes])
        end
      end

      it "creates the Quotation correctly" do
        aggregate_failures do
          expect(Quotations::Quotation.count).to be(1)
          expect(quotation.pickup_address_id).to eq(service.shipment.pickup_address.id)
          expect(quotation.delivery_address_id).to eq(service.shipment.delivery_address.id)
        end
      end

      it "creates the Tenders correctly" do
        tenders = Quotations::Tender.all
        aggregate_failures do
          expect(tenders.count).to be(1)
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
      let!(:legacy_results) { service.detailed_schedules }
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
          expect(legacy_results.length).to eq(4)
          expect(legacy_results.first.keys).to match_array(%i[quote schedules meta notes])
        end
      end

      it "creates the Quotation correctly" do
        aggregate_failures do
          expect(Quotations::Quotation.count).to be(1)
          expect(quotation.pickup_address_id).to eq(service.shipment.pickup_address.id)
          expect(quotation.delivery_address_id).to eq(service.shipment.delivery_address.id)
        end
      end

      it "creates the Tenders correctly" do
        tenders = Quotations::Tender.all
        aggregate_failures do
          expect(tenders.count).to be(4)
          expect(tenders.map { |t| [t.pickup_tenant_vehicle_id, t.tenant_vehicle_id, t.delivery_tenant_vehicle_id] }.uniq).to match_array(desired_tenant_vehicle_combos)
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
      let!(:legacy_results) { service.detailed_schedules }
      let(:desired_tenant_vehicle_combos) do
        [
          [tenant_vehicle.id, tenant_vehicle.id, tenant_vehicle.id, itinerary.id],
          [tenant_vehicle_2.id, tenant_vehicle_2.id, tenant_vehicle_2.id, itinerary_2.id]
        ]
      end

      it "perform a booking calculation" do
        aggregate_failures do
          expect(legacy_results.length).to eq(2)
          expect(legacy_results.first.keys).to match_array(%i[quote schedules meta notes])
        end
      end

      it "creates the Quotation correctly" do
        aggregate_failures do
          expect(Quotations::Quotation.count).to be(1)
          expect(quotation.pickup_address_id).to eq(service.shipment.pickup_address.id)
          expect(quotation.delivery_address_id).to eq(service.shipment.delivery_address.id)
          expect(quotation.creator).to eq(creator)
        end
      end

      it "creates the Tenders correctly" do
        tenders = Quotations::Tender.all
        aggregate_failures do
          expect(tenders.count).to be(2)
          expect(
            tenders.map { |t| [t.pickup_tenant_vehicle_id, t.tenant_vehicle_id, t.delivery_tenant_vehicle_id, t.itinerary_id] }.uniq
          ).to match_array(desired_tenant_vehicle_combos)
        end
      end
    end
  end
end
