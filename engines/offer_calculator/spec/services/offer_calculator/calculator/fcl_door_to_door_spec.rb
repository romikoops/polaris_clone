# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Calculator do
  let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
  let(:load_type) { "container" }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      load_type: "container",
      destination_hub: nil,
      origin_hub: nil,
      desired_start_date: Time.zone.today + 4.days,
      user: user,
      trucking: {
        pre_carriage: {
          address_id: pickup_address.id,
          truck_type: "chassis"
        },
        on_carriage: {
          address_id: delivery_address.id,
          truck_type: "chassis"
        }
      },
      organization: organization)
  end
  let(:container_attributes) do
    [
      {
        "payload_in_kg" => 12_000,
        "size_class" => "fcl_20",
        "quantity" => 1,
        "dangerous_goods" => false
      },
      {
        "payload_in_kg" => 12_000,
        "size_class" => "fcl_40",
        "quantity" => 1,
        "dangerous_goods" => false
      },
      {
        "payload_in_kg" => 12_000,
        "size_class" => "fcl_40_hq",
        "quantity" => 1,
        "dangerous_goods" => false
      }
    ]
  end
  let(:params) do
    ActionController::Parameters.new(
      "shipment" => {
        "id" => shipment.id,
        "direction" => "export",
        "selected_day" => 4.days.from_now.beginning_of_day.to_s,
        "cargo_items_attributes" => [],
        "containers_attributes" => container_attributes,
        "trucking" => {
          "pre_carriage" => {
            address_id: pickup_address.id,
            truck_type: "chassis"
          },
          "on_carriage" => {
            address_id: delivery_address.id,
            truck_type: "chassis"
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
  let(:quotation) { Quotations::Quotation.last }
  let(:creator) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:service) do
    described_class.new(shipment: shipment, params: params, user: user, creator: creator).perform
  end

  include_context "complete_route_with_trucking"

  before do
    Organizations.current_id = organization.id
    allow_any_instance_of(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:address_params)
      .with(:origin).and_return(origin_address_params)
    allow_any_instance_of(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:address_params)
      .with(:destination).and_return(destination_address_params)
    allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
  end

  describe ".perform" do
    context "with calculator errors" do
      let(:shipment_update_handler) {
        instance_double(OfferCalculator::Service::ShipmentUpdateHandler, update_trucking: nil, update_nexuses: nil)
      }

      before do
        allow(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:new).and_return(shipment_update_handler)
        allow(shipment_update_handler).to receive(:update_trucking)
          .and_raise(OfferCalculator::Errors::InvalidPickupAddress)
      end

      it "set the error class on the quotation" do
        aggregate_failures do
          expect { service }.to raise_error(OfferCalculator::Errors::InvalidPickupAddress)
          expect(quotation.error_class).to eq("OfferCalculator::Errors::InvalidPickupAddress")
        end
      end
    end

    context "with offer creator errors" do
      before do
        allow(OfferCalculator::Service::OfferCreator).to receive(:offers)
          .and_raise(OfferCalculator::Errors::OfferBuilder)
      end

      it "set the error class on the quotation" do
        aggregate_failures do
          expect { service }.to raise_error(OfferCalculator::Errors::OfferBuilder)
          expect(quotation.error_class).to eq("OfferCalculator::Errors::OfferBuilder")
          expect(quotation.completed).to be false
        end
      end
    end

    context "with single trucking Availability" do
      let!(:results) { service.detailed_schedules }

      it "perform a booking calulation" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
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
            hub: origin_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: "container",
            truck_type: "chassis",
            tenant_vehicle: trucking_tenant_vehicle_2,
            location: pickup_trucking_location)
          FactoryBot.create(:trucking_with_unit_rates,
            hub: destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: "container",
            truck_type: "chassis",
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

      it "perform a booking calulation" do
        aggregate_failures do
          expect(legacy_results.length).to eq(4)
          expect(
            legacy_results.map { |result| result.dig(:meta, :tender_id) }
          ).to match_array(Quotations::Tender.order(:amount_cents).ids)
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
          expect(tenders.count).to be(4)
          expect(
            tenders.map { |t| [t.pickup_tenant_vehicle_id, t.tenant_vehicle_id, t.delivery_tenant_vehicle_id] }.uniq
          ).to match_array(desired_tenant_vehicle_combos)
        end
      end
    end
  end
end
