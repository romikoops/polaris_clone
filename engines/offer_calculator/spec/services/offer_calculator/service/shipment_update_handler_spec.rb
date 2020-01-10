# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::ShipmentUpdateHandler do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let!(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
  let(:gothenburg_address) { FactoryBot.create(:gothenburg_address) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:base_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      destination_hub: nil,
                      origin_hub: nil,
                      user: user,
                      tenant: tenant)
  end

  let(:cargo_item_attributes) do
  [
    {
      "payload_in_kg"=>120,
      "total_volume"=>0,
      "total_weight"=>0,
      "dimension_x"=>120,
      "dimension_y"=>80,
      "dimension_z"=>120,
      "quantity"=>1,
      "cargo_item_type_id"=> pallet.id,
      "dangerous_goods"=>false,
      "stackable"=>true
    }
  ]
  end

  let(:aggregated_cargo_attributes) do
    {
      "volume"=>2.0,
      "weight"=>1000
    }
  end

  let(:container_attributes) do
    [
      {
      "payload_in_kg"=>12000,
      "size_class"=>'fcl_20',
      "quantity"=>1,
      "dangerous_goods"=>false
    },
      {
      "payload_in_kg"=>12000,
      "size_class"=>'fcl_40',
      "quantity"=>1,
      "dangerous_goods"=>false
    },
      {
      "payload_in_kg"=>12000,
      "size_class"=>'fcl_40_hq',
      "quantity"=>1,
      "dangerous_goods"=>false
    }
  ]
  end

  let(:params) do
    {
      shipment: {
        "id"=> base_shipment.id,
        "direction"=>"export",
        "selected_day"=> 4.days.from_now.beginning_of_day.to_s,
        "cargo_items_attributes"=>[],
        "containers_attributes"=>[],
        "trucking"=>{
          "pre_carriage"=>{"truck_type"=>""},
          "on_carriage"=>{"truck_type"=>""}
        },
        "incoterm"=>{},
        "aggregated_cargo_attributes"=>nil}
    }
  end

  context 'port to port' do
    let(:port_to_port_params) do
      params[:shipment]['origin'] = {
        "latitude"=> origin_hub.latitude,
        "longitude"=> origin_hub.longitude,
        "nexus_id"=> origin_hub.nexus_id,
        "nexus_name"=> origin_hub.nexus.name,
        "country"=> origin_hub.nexus.country.code
      }
      params[:shipment]['destination'] = {
        "latitude"=> destination_hub.latitude,
        "longitude"=> destination_hub.longitude,
        "nexus_id"=> destination_hub.nexus_id,
        "nexus_name"=> destination_hub.nexus.name,
        "country"=> destination_hub.nexus.country.code
      }
      params[:shipment]['cargo_items_attributes'] = cargo_item_attributes
      ActionController::Parameters.new(params)
    end
    let(:service) { described_class.new(shipment: base_shipment, params: port_to_port_params, sandbox: nil) }

    describe '.update_nexuses' do
      it 'updates the nexus' do
        service.update_nexuses
        expect(base_shipment.origin_nexus_id).to eq(origin_hub.nexus_id)
        expect(base_shipment.destination_nexus_id).to eq(destination_hub.nexus_id)
      end
    end

    describe '.update_trucking' do
      it 'updates the trucking' do
        service.update_trucking
        expect(base_shipment.trucking).to eq({"pre_carriage"=>{"truck_type"=>""}, "on_carriage"=>{"truck_type"=>""}})
      end
    end

    describe '.update_incoterm' do
      it 'updates the incoterm' do
        service.update_incoterm
        expect(base_shipment.incoterm_id).to eq(nil)
      end
    end

    describe '.cargo_units' do
      it 'creates the cargo items' do
        service.update_cargo_units
        expect(base_shipment.cargo_items.count).to eq(1)
        cargo_item = base_shipment.cargo_items.first
        expect(cargo_item.dimension_x).to eq(cargo_item_attributes.first['dimension_x'])
        expect(cargo_item.dimension_y).to eq(cargo_item_attributes.first['dimension_y'])
        expect(cargo_item.dimension_z).to eq(cargo_item_attributes.first['dimension_z'])
        expect(cargo_item.payload_in_kg).to eq(cargo_item_attributes.first['payload_in_kg'])
      end

      it 'creates an aggregated_cargo' do
        agg_params = port_to_port_params.dup
        agg_params[:shipment].delete('cargo_items_attributes')
        agg_params[:shipment]['aggregated_cargo_attributes'] = aggregated_cargo_attributes

        agg_service = described_class.new(shipment: base_shipment, params: agg_params, sandbox: nil)
        agg_service.update_cargo_units
        aggregated_cargo = base_shipment.aggregated_cargo
        expect(aggregated_cargo.weight).to eq(aggregated_cargo_attributes['weight'])
        expect(aggregated_cargo.volume).to eq(aggregated_cargo_attributes['volume'])

      end
    end

    describe '.update_selected_day' do
      it 'updates the desired_start_date with the minimum' do
        service.update_selected_day
        expect(base_shipment.desired_start_date).to eq(5.days.from_now.beginning_of_day)
      end
    end

    describe '.update_updated_at' do
      it 'updates the desired_start_date with the minimum' do
        service.update_updated_at
        expect(base_shipment.updated_at > 2.seconds.ago).to be_truthy
      end
    end
  end

  context 'door to door' do
    let(:door_to_door_params) do
      params[:shipment]['origin'] = {
        "number"=> gothenburg_address.street_number,
        "street"=> gothenburg_address.street,
        "zip_code"=> gothenburg_address.zip_code,
        "city"=> gothenburg_address.city,
        "country"=> gothenburg_address.country.name,
        "full_address"=> gothenburg_address.geocoded_address,
        "latitude"=> gothenburg_address.latitude,
        "longitude"=> gothenburg_address.longitude,
        "hub_ids"=>[origin_hub.id]
      }
      params[:shipment]['destination'] = {
        "number"=> shanghai_address.street_number,
        "street"=> shanghai_address.street,
        "zip_code"=> shanghai_address.zip_code,
        "city"=> shanghai_address.city,
        "country"=> shanghai_address.country.name,
        "full_address"=> shanghai_address.geocoded_address,
        "latitude"=> shanghai_address.latitude,
        "longitude"=> shanghai_address.longitude,
        "hub_ids"=>[destination_hub.id]
      }
      params[:shipment]["trucking"] = {
        "pre_carriage"=>{
          "truck_type"=>"chassis"
          },
          "on_carriage"=>{
            "truck_type"=>"side_lifter"
          }
        }
      params[:shipment]["selected_day"] = 10.days.from_now.beginning_of_day.to_s
      params[:shipment]['containers_attributes'] = container_attributes
      ActionController::Parameters.new(params)
    end

    let(:service) do
      base_shipment.update(has_pre_carriage: true, has_on_carriage: true, load_type: 'container')
      described_class.new(shipment: base_shipment, params: door_to_door_params, sandbox: nil)
    end

    describe '.update_nexuses' do
      it 'updates the nexus' do
        service.update_nexuses
        expect(base_shipment.origin_nexus_id).to eq(nil)
        expect(base_shipment.destination_nexus_id).to eq(nil)
      end
    end

    describe '.update_trucking' do
      it 'updates the trucking' do
        service.update_trucking
        expect(base_shipment.trucking.dig('pre_carriage', 'truck_type')).to eq('chassis')
        expect(base_shipment.trucking.dig('on_carriage', 'truck_type')).to eq('side_lifter')
        expect(base_shipment.trucking.dig('pre_carriage', 'address_id').is_a?(Numeric)).to be_truthy
        expect(base_shipment.trucking.dig('on_carriage', 'address_id').is_a?(Numeric)).to be_truthy
      end
    end

    describe '.update_incoterm' do
      it 'updates the incoterm' do
        service.update_incoterm
        expect(base_shipment.incoterm_id).to eq(nil)
      end
    end

    describe '.cargo_units' do
      it 'creates the containers' do
        service.update_cargo_units
        expect(base_shipment.containers.count).to eq(3)
        expect(base_shipment.containers.map(&:size_class)).to match_array(['fcl_20', 'fcl_40', 'fcl_40_hq'])
      end
    end

    describe '.update_selected_day' do
      it 'updates the desired_start_date' do
        service.update_selected_day
        expect(base_shipment.desired_start_date).to eq(10.days.from_now.beginning_of_day)
      end
    end

    describe '.update_updated_at' do
      it 'updates the shipment updated at' do
        service.update_updated_at
        expect(base_shipment.updated_at > 2.seconds.ago).to be_truthy
      end
    end

    describe '.clear_previous_itinerary' do
      it 'return nil when no itinerary' do
        service.clear_previous_itinerary
        expect(base_shipment.itinerary_id).to be_nil
      end
      it 'return removes itinerary and trip' do
        base_shipment.update(itinerary: itinerary, trip: trip)
        service.clear_previous_itinerary
        expect(base_shipment.itinerary_id).to be_nil
        expect(base_shipment.trip_id).to be_nil
      end
    end
  end

  context 'errors' do
    describe '.update_trucking' do
      let(:pickup_params) do
        params[:shipment]['origin'] = {
          "number"=> gothenburg_address.street_number,
          "street"=> gothenburg_address.street,
          "zip_code"=> gothenburg_address.zip_code,
          "city"=> gothenburg_address.city,
          "country"=> gothenburg_address.country.name,
          "full_address"=> gothenburg_address.geocoded_address,
          "latitude"=> gothenburg_address.latitude,
          "longitude"=> gothenburg_address.longitude,
          "hub_ids"=>[origin_hub.id]
        }
        params[:shipment]["trucking"] = {
          "pre_carriage"=>{
            "truck_type"=>"chassis"
            }
          }
        params[:shipment]["selected_day"] = 10.days.from_now.beginning_of_day.to_s
        params[:shipment]['containers_attributes'] = container_attributes
        ActionController::Parameters.new(params)
      end

      let(:pickup_service) do
        base_shipment.update(has_pre_carriage: true, load_type: 'container')
        described_class.new(shipment: base_shipment, params: pickup_params, sandbox: nil)
      end
      let(:dropoff_params) do
        params[:shipment]['origin'] = {
          "latitude"=> origin_hub.latitude,
          "longitude"=> origin_hub.longitude,
          "nexus_id"=> origin_hub.nexus_id,
          "nexus_name"=> origin_hub.nexus.name,
          "country"=> origin_hub.nexus.country.code
        }
        params[:shipment]['destination'] = {
          "number"=> gothenburg_address.street_number,
          "street"=> gothenburg_address.street,
          "zip_code"=> gothenburg_address.zip_code,
          "city"=> gothenburg_address.city,
          "country"=> gothenburg_address.country.name,
          "full_address"=> gothenburg_address.geocoded_address,
          "latitude"=> gothenburg_address.latitude,
          "longitude"=> gothenburg_address.longitude,
          "hub_ids"=>[origin_hub.id]
        }
        params[:shipment]["trucking"] = {
          "on_carriage"=>{
            "truck_type"=>"chassis"
            }
          }
        params[:shipment]["selected_day"] = 10.days.from_now.beginning_of_day.to_s
        params[:shipment]['containers_attributes'] = container_attributes
        ActionController::Parameters.new(params)
      end

      let(:dropoff_service) do
        base_shipment.update(has_on_carriage: true, load_type: 'container')
        described_class.new(shipment: base_shipment, params: dropoff_params, sandbox: nil)
      end


      it 'raises error when the pickup addresses arent found' do
        allow(Legacy::Address).to receive(:new_from_raw_params).and_return(Legacy::Address.new)

        expect { pickup_service.update_trucking }.to raise_error(OfferCalculator::Calculator::InvalidPickupAddress)
      end

      it 'raises error when the delivery addresses arent found' do
        allow(Legacy::Address).to receive(:new_from_raw_params).and_return(Legacy::Address.new)

        expect { dropoff_service.update_trucking }.to raise_error(OfferCalculator::Calculator::InvalidDeliveryAddress)
      end
    end
  end
end
# update_incoterm
# update_cargo_units
# update_selected_day
# update_updated_at
