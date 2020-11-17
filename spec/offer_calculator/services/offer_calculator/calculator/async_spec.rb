# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Calculator do
  ActiveJob::Base.queue_adapter = :test

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
      "async" => true,
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
          "nexus_id" => origin_hub.nexus_id,
          "nexus_name" => origin_hub.nexus.name,
          "country" => origin_hub.nexus.country.code,
          "full_address" => pickup_address.geocoded_address
        },
        "destination" => {
          "nexus_id" => destination_hub.nexus_id,
          "nexus_name" => destination_hub.nexus.name,
          "country" => destination_hub.nexus.country.code,
          "full_address" => delivery_address.geocoded_address
        },
        "incoterm" => {},
        "aggregated_cargo_attributes" => nil
      }
    )
  end
  let(:quotation) { service.quotation }
  let(:wheelhouse) { false }
  let(:service) do
    described_class.new(
      shipment: shipment,
      params: params,
      user: user,
      creator: user,
      wheelhouse: wheelhouse
    )
  end

  include_context "complete_route_with_trucking"

  before do
    Organizations.current_id = organization.id
  end

  describe ".perform" do
    let!(:result) { service.perform }

    context "with single trucking Availability" do
      it "queues the job and returns the quotation" do
        expect(result).to be_a(OfferCalculator::Results)
      end
    end
  end
end
