# frozen_string_literal: true

RSpec.shared_context "routing_line_sections" do
  let(:pickup_point) do
    FactoryBot.build(:journey_route_point,
      coordinates: origin_coordinates,
      name: origin_text)
  end
  let(:delivery_point) do
    FactoryBot.build(:journey_route_point,
      coordinates: destination_coordinates,
      name: destination_text)
  end
  let(:origin_locode) { "DEHAM" }
  let(:destination_locode) { "CNSHA" }
  let(:origin_transfer_latitude) { 57.694253 }
  let(:origin_transfer_longitude) { 11.854048 }
  let(:origin_transfer_text) { "Hamburg" }
  let(:origin_transfer_coordinates) {
    RGeo::Geos.factory(srid: 4326).point(origin_transfer_longitude, origin_transfer_latitude)
  }
  let(:destination_transfer_latitude) { 31.232014 }
  let(:destination_transfer_longitude) { 121.4867159 }
  let(:destination_transfer_text) { "Shanghai" }
  let(:destination_transfer_coordinates) {
    RGeo::Geos.factory(srid: 4326).point(destination_transfer_longitude, destination_transfer_latitude)
  }
  let(:freight_mot) { "ocean" }
  let(:origin_transfer) do
    FactoryBot.build(:journey_route_point,
      coordinates: origin_transfer_coordinates,
      locode: origin_locode,
      name: origin_transfer_text)
  end
  let(:destination_transfer) do
    FactoryBot.build(:journey_route_point,
      coordinates: destination_transfer_coordinates,
      locode: destination_locode,
      name: destination_transfer_text)
  end

  let(:pre_carriage_section) do
    FactoryBot.build(:journey_route_section,
      from: pickup_point,
      to: origin_transfer,
      mode_of_transport: "carriage",
      order: 0,
      service: pre_carriage_service,
      carrier: pre_carriage_carrier)
  end
  let(:origin_transfer_section) do
    FactoryBot.build(:journey_route_section,
      from: origin_transfer,
      to: origin_transfer,
      order: 1,
      mode_of_transport: freight_mot,
      service: freight_carriage_service,
      carrier: freight_carriage_carrier)
  end
  let(:freight_section) do
    FactoryBot.build(:journey_route_section,
      from: origin_transfer,
      to: destination_transfer,
      order: 2,
      mode_of_transport: freight_mot,
      service: freight_carriage_service,
      carrier: freight_carriage_carrier)
  end
  let(:destination_transfer_section) do
    FactoryBot.build(:journey_route_section,
      from: destination_transfer,
      to: destination_transfer,
      order: 3,
      mode_of_transport: freight_mot,
      service: freight_carriage_service,
      carrier: freight_carriage_carrier)
  end
  let(:on_carriage_section) do
    FactoryBot.build(:journey_route_section,
      from: destination_transfer,
      to: delivery_point,
      order: 4,
      mode_of_transport: "carriage",
      service: on_carriage_service,
      carrier: on_carriage_carrier)
  end
end
