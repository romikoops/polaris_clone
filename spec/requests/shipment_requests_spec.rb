# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/request_spec_helpers'
Dir["#{Rails.root}/spec/support/auxiliary_constants/shipments/*.rb"].each do |file_path|
  require file_path
end

describe 'Shipment requests', type: :request do

  let(:trip) { create(:trip) }
  let(:user) { create(:user, tenant: tenant) }
  let(:shipment) { create(:shipment, load_type: load_type, direction: direction, user: user, tenant: tenant, origin_nexus: origin_nexus, destination_nexus: destination_nexus, trip: itinerary.trips.first, itinerary: itinerary) }
  let(:origin_nexus) { create(:address, hub: origin_hub) }
  let(:destination_nexus) { create(:address, hub: destination_hub) }
  let!(:itinerary) { create(:itinerary, tenant: tenant, stops: [origin_stop, destination_stop], layovers: [origin_layover, destination_layover], trips: [trip]) }
  let(:origin_hub) { create(:hub, tenant: tenant) }
  let(:destination_hub) { create(:hub, tenant: tenant) }
  let(:origin_stop) { create(:stop, index: 0, hub_id: origin_hub.id, layovers: [origin_layover]) }
  let(:destination_stop) { create(:stop, index: 1, hub_id: destination_hub.id, layovers: [destination_layover]) }
  let(:origin_layover) { create(:layover, stop_index: 0, trip: trip) }
  let(:destination_layover) { create(:layover, stop_index: 1, trip: trip) }
  let!(:container) { create(:container, shipment: shipment) }
  let!(:transport_category) { create(:transport_category, vehicle: trip.tenant_vehicle.vehicle) }
  let!(:pricing) { create(:pricing, tenant: tenant, transport_category: transport_category, itinerary: itinerary) }
  let(:trucking) { { on_carriage: { truck_type: '' }, pre_carriage: { truck_type: '' } } }
  let(:charge_breakdown)          { create(:charge_breakdown, trip_id: trip.id, shipment: shipment) }
  let(:price)                     { create(:price) }

  let!(:charge) {
    create(:charge,
      charge_breakdown:         charge_breakdown,
      charge_category:          ChargeCategory.base_node,
      children_charge_category: ChargeCategory.grand_total,
      price:                    price
    )
  }

  context 'user logged in' do
    let(:direction) { 'import' }

    let(:load_type) { 'container' }

    include_context 'logged_in'

    context '#subdomain_create_shipment_path' do
      let(:response_data) do
        {
          # TBD - check cargo_item_types
          routes:                 ROUTES,
          maxDimensions:          MAX_DIMENSIONS,
          maxAggregateDimensions: MAX_AGGREGATE_DIMENSIONS,
          shipment: {
            user_id: tenant.users.last.id, status: 'booking_process_started', load_type: load_type, tenant_id: tenant.id
          }
        }
      end

      it 'Writes an empty shipment to the DB', pending: 'Outdated spec' do
        post subdomain_create_shipment_path(subdomain_id: 'demo'), params: { details: { loadType: load_type, direction: direction } }
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end

    context '#subdomain_shipment_get_offers_path' do
      let(:planned_origin_drop_off_date) { Time.current.iso8601(3).to_s }

      let!(:response_data) do
        {
          shipment: {
            load_type: load_type, id: shipment.id, planned_origin_drop_off_date: planned_origin_drop_off_date, origin_nexus_id: origin_nexus.id, destination_nexus_id: destination_nexus.id, tenant_id: tenant.id, uuid: shipment.uuid, imc_reference: shipment.imc_reference, direction: direction
          },
          originHubs: [
            {
              id: origin_hub.id, tenant_id: tenant.id, address_id: origin_hub.address_id, name: 'Gothenburg Port', hub_type: 'ocean', latitude: nil, longitude: nil, hub_status: 'active', hub_code: 'GOO1', trucking_type: nil, photo: nil, nexus_id: origin_hub.nexus_id
            }
          ],
          destinationHubs: [
            {
              id: destination_hub.id, tenant_id: tenant.id, address_id: destination_hub.address_id, name: 'Gothenburg Port', hub_type: 'ocean', latitude: nil, longitude: nil, hub_status: 'active', hub_code: 'GOO1', trucking_type: nil, photo: nil, nexus_id: destination_hub.nexus_id
            }
          ],
          cargoUnits: [
            {
              id: Container.last.id+1, shipment_id: shipment.id, weight_class: '<= 5.0t', payload_in_kg: '0.0', tare_weight: '0.0', gross_weight: '0.0', dangerous_goods: false, cargo_class: "fcl_20", hs_codes: [], customs_text: nil, quantity: 1, unit_price: { value: '1111.0', currency: 'EUR' }
            }
          ]
        }
      end

      it 'Retrieves the shipment data required for the next step in the booking proccess.', pending: 'Outdated spec' do
        stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json?address=%7B:country=%3E%22Sweden%22%7D&key=AIzaSyBEJhYgBzz9MVTOybSNSu5IMPz5eC2-J5M&language=en&sensor=false")
          .with(headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          })
          .to_return(
            status: 200,
            body: {"data"=>{"address_components"=>[{"long_name"=>"Sweden", "short_name"=>"SE", "types"=>["country", "political"]}], "formatted_address"=>"Sweden", "geometry"=>{"bounds"=>{"northeast"=>{"lat"=>69.0599709, "lng"=>24.1773101}, "southwest"=>{"lat"=>55.0059799, "lng"=>10.5798}}, "address"=>{"lat"=>60.12816100000001, "lng"=>18.643501}, "address_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lat"=>69.0599709, "lng"=>24.1773101}, "southwest"=>{"lat"=>55.0059799, "lng"=>10.5798}}}, "partial_match"=>true, "place_id"=>"ChIJ8fA1bTmyXEYRYm-tjaLruCI", "types"=>["country", "political"]}}.to_json,
            headers: {}
          )

        stub_request(:get, "http://data.fixer.io/latest?access_key=#{Settings.fixer.api_key}&base=EUR")
          .with(
            headers: {
              'Connection'=>'close',
              'Host'=>'data.fixer.io',
              'User-Agent'=>'http.rb/3.3.0'
            }
          )
          .to_return(status: 200, body: { base: 'EUR', rates: { AUD: 1.5983, BGN: 1.9558, BRL: 4.1892, CAD: 1.5557, CHF: 1.197, CNY: 7.7449, CZK: 25.34, DKK: 7.4477, GBP: 0.87608, HKD: 9.6568, HRK: 7.411, HUF: 310.52, IDR: 17_143.0, ILS: 4.3435, INR: 81.39, ISK: 123.3, JPY: 132.41, KRW: 1316.3, MXN: 22.742, MYR: 4.7924, NOK: 9.605, NZD: 1.7032, PHP: 64.179, PLN: 4.1677, RON: 4.6586, RUB: 75.738, SEK: 10.37, SGD: 1.6172, THB: 38.552, TRY: 4.9803, USD: 1.2309, ZAR: 14.801 } }.to_json, headers: {})

        post subdomain_shipment_get_offers_path(subdomain_id: 'demo', shipment_id: shipment.id),
          params: { shipment: { selected_day: planned_origin_drop_off_date, origin: { nexus_id: origin_nexus.id, nexus_name: origin_nexus.name, latitude: origin_nexus.latitude, longitude: origin_nexus.longitude }, destination: { nexus_id: destination_nexus.id, nexus_name: destination_nexus.name, latitude: destination_nexus.latitude, longitude: destination_nexus.longitude }, incoterm: '', delay: '10', trucking: trucking, containers_attributes: [{ payload_in_kg: 0, sizeClass: 'fcl_20', tareWeight: 0, quantity: 1, dangerous_goods: false }] } }
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end

    context '#subdomain_shipment_choose_offer_path' do
      let(:response_data) do
        {
          shipment: {
            user_id: user.id, tenant_id: tenant.id, itinerary_id: itinerary.id, trip_id: trip.id, load_type: load_type, id: shipment.id, origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, status: nil, direction: direction, pre_carriage_distance_km: nil, on_carriage_distance_km: nil, origin_nexus_id: origin_nexus.id, destination_nexus_id: destination_nexus.id, uuid: shipment.uuid, imc_reference: shipment.imc_reference
          },
          hubs: {
            startHub: {
              data: { id: origin_hub.id, tenant_id: tenant.id, address_id: origin_hub.address_id, name: origin_hub.name, hub_type: origin_hub.hub_type, latitude: nil, longitude: nil, hub_status: origin_hub.hub_status, hub_code: origin_hub.hub_code, trucking_type: nil, photo: nil, nexus_id: origin_hub.nexus_id },
              address: origin_hub.nexus.given_attributes
            },
            endHub: {
              data: { id: destination_hub.id, tenant_id: tenant.id, address_id: destination_hub.address_id, name: destination_hub.name, hub_type: destination_hub.hub_type, latitude: destination_hub.latitude, longitude: destination_hub.longitude, hub_status: destination_hub.hub_status, hub_code: destination_hub.hub_code, nexus_id: destination_hub.nexus_id },
              address: destination_hub.nexus.given_attributes
            }
          },
          contacts: [], userLocations: [],
          schedule: {
            itinerary_id: itinerary.id.to_s, eta: destination_layover.eta.iso8601(3), etd: origin_layover.etd.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', trip_id: trip.id.to_s, origin_layover_id: origin_layover.id.to_s, destination_layover_id: destination_layover.id.to_s
          },
          dangerousGoods: false, documents: {},
          containers: [
            {
              id: container.id, shipment_id: shipment.id, size_class: 'fcl_20', weight_class: '14t', payload_in_kg: '10000.0', tare_weight: '1000.0', gross_weight: '11000.0', dangerous_goods: false, cargo_class: 'fcl_20', hs_codes: [], customs_text: nil, quantity: 1, unit_price: nil
            }
          ],
          cargoItems: [], customs: { import: { unknown: true }, export: { unknown: true }, total: { total: { value: 0, currency: 'EUR' } } },
          addresses: {
            origin: {
              id: origin_nexus.id, name: origin_nexus.name, address_type: nil, latitude: origin_nexus.latitude, longitude: origin_nexus.longitude, geocoded_address: origin_nexus.geocoded_address, zip_code: origin_nexus.zip_code, city: origin_nexus.city
            },
            destination: {
              id: destination_nexus.id, name: destination_nexus.name, address_type: nil, latitude: destination_nexus.latitude, longitude: destination_nexus.longitude, geocoded_address: destination_nexus.geocoded_address, zip_code: destination_nexus.zip_code, city: destination_nexus.city
            }
          }
        }
      end

      it 'Updates the existing shipment with information about which offer was actually chosen', pending: 'Outdated spec' do
        post subdomain_shipment_choose_offer_path(subdomain_id: 'demo', shipment_id: shipment.id), params: {
          customs_credit: nil,
          user_id: user.id,
          schedule: {
            origin_hub:             origin_hub.as_json(only: %i(id name)),
            destination_hub:        destination_hub.as_json(only: %i(id name)),
            mode_of_transport:      "ocean",
            itinerary_id:           itinerary.id,
            eta:                    destination_layover.eta.iso8601(3),
            etd:                    origin_layover.etd.iso8601(3),
            closing_date:           origin_layover.closing_date.iso8601(3),
            trip_id:                trip.id,
            origin_layover_id:      origin_layover.id,
            destination_layover_id: destination_layover.id,
            total_price:            { value: '1111.0', currency: 'EUR' }
          }
        }

        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end

    context '#subdomain_shipment_update_shipment_path' do
      let(:cargo_notes) { "example note" }
      let(:response_data) do
        {
          shipment:   {}, # TBD
          cargoItems: [],
          containers: [
            {
              id: container.id, shipment_id: shipment.id, size_class: 'fcl_20', weight_class: '14t', payload_in_kg: '10000.0', tare_weight: '1000.0', gross_weight: '11000.0', dangerous_goods: false, cargo_class: 'fcl_20', hs_codes: [], customs_text: nil, quantity: 1, unit_price: nil
            }
          ],
          aggregatedCargo: nil,
          addresses: {
            origin: {
              id: origin_nexus.id, name: origin_nexus.name, address_type: nil, latitude: origin_nexus.latitude, longitude: origin_nexus.longitude, geocoded_address: origin_nexus.geocoded_address, zip_code: origin_nexus.zip_code, city: origin_nexus.city
            },
            destination: {
              id: destination_nexus.id, name: destination_nexus.name, address_type: nil, latitude: destination_nexus.latitude, longitude: destination_nexus.longitude, geocoded_address: destination_nexus.geocoded_address, zip_code: destination_nexus.zip_code, city: destination_nexus.city
            }
          },
          consignee:      {}, # TBD
          notifyees:      [],
          shipper:        {}, # TBD
          documents:      [], # TBD
          cargoItemTypes: {}  # TBD
        }
      end

      before do
        shipment.update!(itinerary: itinerary, containers: [container], origin_hub: origin_hub, destination_hub: destination_hub, trucking: trucking)
      end

      it 'Sets the shipment contacts & data', pending: 'Outdated spec' do
        require "geocoder"
        # Countries

        # UK
        stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json?address=%7B:country=%3E%22UK%22%7D&key=AIzaSyBEJhYgBzz9MVTOybSNSu5IMPz5eC2-J5M&language=en&sensor=false")
          .with(headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          })
          .to_return(
            status: 200,
            body: {"results"=>[{"address_components"=>[{"long_name"=>"United Kingdom", "short_name"=>"GB", "types"=>["country", "political"]}], "formatted_address"=>"United Kingdom", "geometry"=>{"bounds"=>{"northeast"=>{"lat"=>60.91569999999999, "lng"=>33.9165549}, "southwest"=>{"lat"=>34.5614, "lng"=>-8.8988999}}, "address"=>{"lat"=>55.378051, "lng"=>-3.435973}, "address_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lat"=>60.91569999999999, "lng"=>33.9165549}, "southwest"=>{"lat"=>34.5614, "lng"=>-8.8988999}}}, "partial_match"=>true, "place_id"=>"ChIJqZHHQhE7WgIReiWIMkOg-MQ", "types"=>["country", "political"]}], "status"=>"OK"}.to_json,
            headers: {}
          )

        # Sweden
        stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json?address=%7B:country=%3E%22Sweden%22%7D&key=AIzaSyBEJhYgBzz9MVTOybSNSu5IMPz5eC2-J5M&language=en&sensor=false")
          .with(headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          })
          .to_return(
            status: 200,
            body: {"results"=>[{"address_components"=>[{"long_name"=>"Sweden", "short_name"=>"SE", "types"=>["country", "political"]}], "formatted_address"=>"Sweden", "geometry"=>{"bounds"=>{"northeast"=>{"lat"=>69.0599709, "lng"=>24.1773101}, "southwest"=>{"lat"=>55.0059799, "lng"=>10.5798}}, "address"=>{"lat"=>60.12816100000001, "lng"=>18.643501}, "address_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lat"=>69.0599709, "lng"=>24.1773101}, "southwest"=>{"lat"=>55.0059799, "lng"=>10.5798}}}, "partial_match"=>true, "place_id"=>"ChIJ8fA1bTmyXEYRYm-tjaLruCI", "types"=>["country", "political"]}], "status"=>"OK"}.to_json,
            headers: {}
          )

        # Addresses

        # Tuna St
        stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json?address=Tuna%20St%2064,%2090731%20San%20Pedro,%20Sweden&key=AIzaSyBEJhYgBzz9MVTOybSNSu5IMPz5eC2-J5M&language=en&sensor=false")
          .with(headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          })
          .to_return(
            status: 200,
            body: {"results"=>[{"address_components"=>[{"long_name"=>"Sweden", "short_name"=>"SE", "types"=>["country", "political"]}], "formatted_address"=>"Sweden", "geometry"=>{"bounds"=>{"northeast"=>{"lat"=>69.0599709, "lng"=>24.1773101}, "southwest"=>{"lat"=>55.0059799, "lng"=>10.5798}}, "address"=>{"lat"=>60.12816100000001, "lng"=>18.643501}, "address_type"=>"APPROXIMATE", "viewport"=>{"northeast"=>{"lat"=>69.0599709, "lng"=>24.1773101}, "southwest"=>{"lat"=>55.0059799, "lng"=>10.5798}}}, "partial_match"=>true, "place_id"=>"ChIJ8fA1bTmyXEYRYm-tjaLruCI", "types"=>["country", "political"]}], "status"=>"OK"}.to_json,
            headers: {}
          )

        # College Rd
        stub_request(:get, "https://maps.googleapis.com/maps/api/geocode/json?address=College%20Rd%201,%20PO13LX%20Portsmouth&key=AIzaSyBEJhYgBzz9MVTOybSNSu5IMPz5eC2-J5M&language=en&sensor=false")
          .with(headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          })
          .to_return(
            status: 200,
            body: {"results"=>[{"address_components"=>[{"long_name"=>"1", "short_name"=>"1", "types"=>["street_number"]}, {"long_name"=>"College Road", "short_name"=>"College Rd", "types"=>["route"]}, {"long_name"=>"Portsmouth", "short_name"=>"Portsmouth", "types"=>["postal_town"]}, {"long_name"=>"Portsmouth", "short_name"=>"Portsmouth", "types"=>["administrative_area_level_2", "political"]}, {"long_name"=>"England", "short_name"=>"England", "types"=>["administrative_area_level_1", "political"]}, {"long_name"=>"United Kingdom", "short_name"=>"GB", "types"=>["country", "political"]}, {"long_name"=>"PO1 3LX", "short_name"=>"PO1 3LX", "types"=>["postal_code"]}], "formatted_address"=>"1 College Rd, Portsmouth PO1 3LX, UK", "geometry"=>{"address"=>{"lat"=>50.8000106, "lng"=>-1.1066824}, "address_type"=>"ROOFTOP", "viewport"=>{"northeast"=>{"lat"=>50.8013595802915, "lng"=>-1.105333419708498}, "southwest"=>{"lat"=>50.7986616197085, "lng"=>-1.108031380291502}}}, "place_id"=>"ChIJsY5dan9ddEgR8NM3lL61DpM", "types"=>["premise"]}], "status"=>"OK"}.to_json,
            headers: {}
          )

        post subdomain_shipment_update_shipment_path(subdomain_id: 'demo', shipment_id: shipment.id), as: :json, params: {
          shipment: {
            user_id: user.id,
            shipper:   SHIPPER,
            consignee: CONSIGNEE,
            notifyees: [],
            hsCodes: {},
            totalGoodsValue: {
              value: "1000",
              currency: "EUR"
            },
            cargoNotes: cargo_notes,
            insurance: {
              bool: nil,
              val: 2.127786110567946
            },
            customs: {
              import: { bool: false, val: 0 },
              export: { bool: false, val: 0 },
              total: { val: 0 }
            },
            hsTexts: {},
            incotermText: "",
            customsCredit: false
          }
        }
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end

    context '#subdomain_shipment_request_shipment_path' do
      let(:role) { create(:role, name: 'admin') }
      let!(:admin) { create(:user, tenant: tenant, role: role) }
      let(:response_data) do
        {
          shipment: {
            status: "requested_by_unconfirmed_account", id: shipment.id, load_type: load_type, direction: direction, origin_nexus_id: origin_nexus.id, destination_nexus_id: destination_nexus.id, uuid: shipment.uuid, imc_reference: shipment.imc_reference, tenant_id: tenant.id, itinerary_id: itinerary.id, trucking: trucking, customs_credit: false, total_price: nil, total_goods_value: nil, trip_id: trip.id, eori: nil, notes: nil, incoterm: nil, insurance: nil, customs: nil
          }
        }
      end

      before do
        shipment.update!(itinerary: itinerary, trip: trip, trucking: trucking)
      end

      it 'Is for confirming the details of the shipment displayed on the page and finalizing the booking request.', pending: 'Outdated spec' do
        allow(ShippingTools).to receive(:tenant_notification_email).once
        allow(ShippingTools).to receive(:shipper_notification_email).once
        post subdomain_shipment_request_shipment_path(subdomain_id: 'demo', shipment_id: shipment.id)
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end
  end
end
