# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/request_spec_helpers'

describe 'Shipment requests', type: :request do

  let(:shipment) { create(:shipment, load_type: load_type, direction: direction, tenant: tenant, origin: origin, destination: destination, containers: [container]) }
  let(:origin) { create(:location, hubs: [origin_hub]) }
  let(:destination) { create(:location, hubs: [destination_hub]) }
  let!(:itinerary) { create(:itinerary, tenant: tenant, stops: [origin_stop, destination_stop], layovers: [origin_layover, destination_layover], trips: [trip]) }
  let(:origin_hub) { create(:hub, tenant: tenant) }
  let(:destination_hub) { create(:hub, tenant: tenant) }
  let(:origin_stop) { create(:stop, index: 0, hub_id: origin_hub.id, layovers: [origin_layover]) }
  let(:destination_stop) { create(:stop, index: 1, hub_id: destination_hub.id, layovers: [destination_layover]) }
  let(:origin_layover) { create(:layover, stop_index: 0, trip: trip) }
  let(:destination_layover) { create(:layover, stop_index: 1, trip: trip) }
  let(:trip) { create(:trip) }
  let(:container) { create(:container) }
  let!(:transport_category) { create(:transport_category, vehicle: trip.tenant_vehicle.vehicle) }
  let!(:pricing) { create(:pricing, tenant: tenant, transport_category: transport_category, itinerary: itinerary) }
  let(:schedules_charges) { { [origin_hub.id, destination_hub.id].join('-').to_sym => { trucking_on: {}, trucking_pre: {}, import: {}, export: {}, cargo: { shipment.containers.last.id.to_s.to_sym => { total: { value: '1111.0', currency: 'EUR' }, BAS: { value: '1111.0', currency: 'EUR' } } }, total: { value: '1111.0', currency: 'EUR' } } } }

  context 'user logged in' do
    let(:direction) { 'import' }

    let(:load_type) { 'container' }

    include_context 'logged_in'

    context '#subdomain_create_shipment_path' do
      let(:response_data) do
        {
          allNexuses: { origins: [], destinations: [] },
          cargoItemTypes: [], itineraries: [],
          maxDimensions: { dimensionX: '590.0', dimensionY: '234.2', dimensionZ: '228.0', payloadInKg: '21770.0' },
          shipment: {
            user_id: tenant.users.last.id, origin_id: nil, destination_id: nil, route_id: nil, status: 'booking_process_started', load_type: load_type, planned_pickup_date: nil, has_pre_carriage: nil, pre_carriage_distance_km: nil, has_on_carriage: nil, on_carriage_distance_km: nil, cargo_notes: nil, haulage: nil, hs_code: [], schedules_charges: nil, schedule_set: [], tenant_id: tenant.id, planned_eta: nil, planned_etd: nil, itinerary_id: nil, trucking: { on_carriage: { truck_type: '' }, pre_carriage: { truck_type: '' } }, customs_credit: false, total_price: nil, total_goods_value: nil, trip_id: nil, eori: nil, direction: direction, notes: nil, incoterm: nil, origin_hub_id: nil, destination_hub_id: nil, booking_placed_at: nil, insurance: nil, customs: nil, transport_category_id: nil
          }
        }
      end

      it 'Writes an empty shipment to the DB' do
        post subdomain_create_shipment_path(subdomain_id: 'demo'), params: { details: { loadType: load_type, direction: direction } }
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end

    context '#subdomain_shipment_get_offers_path' do

      let(:planned_pickup_date) { Time.current.iso8601(3).to_s }

      let(:response_schedules_charges) { { [origin_hub.id, destination_hub.id].join('-').to_sym => { trucking_on: {}, trucking_pre: {}, import: {}, export: {}, cargo: { (Container.last.id+1).to_s.to_sym => { total: { value: '1111.0', currency: 'EUR' }, BAS: { value: '1111.0', currency: 'EUR' } } }, total: { value: '1111.0', currency: 'EUR' } } } }


      let!(:response_data) do
        {
          has_pre_carriage: nil, has_on_carriage: nil,
          truck_seconds_pre_carriage: 0,
          shipment: {
            has_pre_carriage: nil, has_on_carriage: nil, trucking: { on_carriage: { truck_type: '' } }, incoterm: '', load_type: load_type, id: shipment.id, planned_pickup_date: planned_pickup_date, origin_id: origin.id, destination_id: destination.id, tenant_id: tenant.id, route_id: nil, uuid: shipment.uuid, imc_reference: shipment.imc_reference, status: nil, pre_carriage_distance_km: nil, on_carriage_distance_km: nil, cargo_notes: nil, haulage: nil, hs_code: [], schedules_charges: response_schedules_charges, schedule_set: [], planned_eta: nil, planned_etd: nil, itinerary_id: nil, customs_credit: false, total_price: { value: '1111.0', currency: 'EUR' }, total_goods_value: nil, trip_id: nil, eori: nil, direction: direction, notes: nil, origin_hub_id: nil, destination_hub_id: nil, booking_placed_at: nil, insurance: nil, customs: nil, transport_category_id: nil
          },
          total_price: {
            total: '1111.0', currency: 'EUR', cargo: { value: 0, currency: '' }
          },
          schedules: [
            {
              itinerary_id: itinerary.id, eta: origin_layover.eta.iso8601(3), etd: origin_layover.eta.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', hub_route_key: [origin_hub.id, destination_hub.id].join('-'), tenant_id: tenant.id, trip_id: trip.id, origin_layover_id: origin_layover.id, destination_layover_id: destination_layover.id,
              total: { value: '1111.0', currency: 'EUR' }
            }
          ],
          originHubs: [
            {
              id: origin_hub.id, tenant_id: tenant.id, location_id: origin_hub.location_id, name: 'Gothenburg Port', hub_type: 'ocean', latitude: nil, longitude: nil, hub_status: 'active', hub_code: 'GOO1', trucking_type: nil, photo: nil, nexus_id: origin_hub.nexus_id
            }
          ],
          destinationHubs: [
            {
              id: destination_hub.id, tenant_id: tenant.id, location_id: destination_hub.location_id, name: 'Gothenburg Port', hub_type: 'ocean', latitude: nil, longitude: nil, hub_status: 'active', hub_code: 'GOO1', trucking_type: nil, photo: nil, nexus_id: destination_hub.nexus_id
            }
          ],
          cargoUnits: [
            {
              id: Container.last.id+1, shipment_id: shipment.id, size_class: 'fcl_20', weight_class: '<= 5.0t', payload_in_kg: '0.0', tare_weight: '0.0', gross_weight: '0.0', dangerous_goods: false, cargo_class: nil, hs_codes: [], customs_text: nil, quantity: 1, unit_price: { value: '1111.0', currency: 'EUR' }
            }
          ]
        }
      end

      it 'Retrieves the shipment data required for the next step in the booking proccess.' do
        stub_request(:get, 'https://api.fixer.io/latest?base=EUR')
          .with(headers: { Host: 'api.fixer.io' })
          .to_return(status: 200, body: { base: 'EUR', rates: { AUD: 1.5983, BGN: 1.9558, BRL: 4.1892, CAD: 1.5557, CHF: 1.197, CNY: 7.7449, CZK: 25.34, DKK: 7.4477, GBP: 0.87608, HKD: 9.6568, HRK: 7.411, HUF: 310.52, IDR: 17_143.0, ILS: 4.3435, INR: 81.39, ISK: 123.3, JPY: 132.41, KRW: 1316.3, MXN: 22.742, MYR: 4.7924, NOK: 9.605, NZD: 1.7032, PHP: 64.179, PLN: 4.1677, RON: 4.6586, RUB: 75.738, SEK: 10.37, SGD: 1.6172, THB: 38.552, TRY: 4.9803, USD: 1.2309, ZAR: 14.801 } }.to_json, headers: {})

        post subdomain_shipment_get_offers_path(subdomain_id: 'demo', shipment_id: shipment.id), params: { shipment: { planned_pickup_date: planned_pickup_date, origin_id: origin.id, destination_id: destination.id, incoterm: '', delay: '1', trucking: { on_carriage: { truck_type: '' } }, containers_attributes: [{ payload_in_kg: 0, sizeClass: 'fcl_20', tareWeight: 0, quantity: 1, dangerous_goods: false }] } }

        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end

    context '#subdomain_shipment_choose_offer_path' do
      let(:response_data) do
        {
          shipment: {
            user_id: user.id, customs_credit: nil, total_price: nil, schedule_set: [{ itinerary_id: itinerary.id.to_s, eta: origin_layover.eta.iso8601(3), etd: origin_layover.eta.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', hub_route_key: [origin_hub.id, destination_hub.id].join('-'), tenant_id: tenant.id.to_s, trip_id: trip.id.to_s, origin_layover_id: origin_layover.id.to_s, destination_layover_id: destination_layover.id.to_s, total: { value: '1111.0', currency: 'EUR' } }], itinerary_id: itinerary.id, trip_id: trip.id, load_type: load_type, id: shipment.id, origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, status: nil, direction: direction, planned_pickup_date: nil, pre_carriage_distance_km: nil, on_carriage_distance_km: nil, origin_id: origin.id, destination_id: destination.id, route_id: nil, uuid: shipment.uuid, imc_reference: shipment.imc_reference, has_pre_carriage: nil, has_on_carriage: nil, cargo_notes: nil, haulage: nil, hs_code: [], schedules_charges: nil, tenant_id: tenant.id, planned_eta: nil, planned_etd: nil, trucking: { on_carriage: { truck_type: '' }, pre_carriage: { truck_type: '' } }, total_goods_value: nil, eori: nil, notes: nil, incoterm: nil, booking_placed_at: nil, insurance: nil, customs: nil, transport_category_id: nil
          },
          hubs: {
            startHub: { data: { id: origin_hub.id, tenant_id: tenant.id, location_id: origin_hub.location_id, name: origin_hub.name, hub_type: origin_hub.hub_type, latitude: nil, longitude: nil, hub_status: origin_hub.hub_status, hub_code: origin_hub.hub_code, trucking_type: nil, photo: nil, nexus_id: origin_hub.nexus_id }, location: { id: origin_hub.nexus_id, name: origin.name, location_type: nil, latitude: origin.latitude, longitude: origin.longitude, geocoded_address: origin.geocoded_address, street: nil, street_number: nil, zip_code: nil, city: origin.city, country: origin.country, street_address: nil, province: nil, photo: nil, premise: nil } }, endHub: { data: { id: destination_hub.id, tenant_id: tenant.id, location_id: destination_hub.location_id, name: destination_hub.name, hub_type: destination_hub.hub_type, latitude: nil, longitude: nil, hub_status: destination_hub.hub_status, hub_code: destination_hub.hub_code, trucking_type: nil, photo: nil, nexus_id: destination_hub.nexus_id }, location: { id: destination.id, name: destination.name, location_type: nil, latitude: destination.latitude, longitude: destination.longitude, geocoded_address: destination.geocoded_address, street: nil, street_number: nil, zip_code: nil, city: destination.city, country: destination.country, street_address: nil, province: nil, photo: nil, premise: nil } }
          },
          contacts: [], userLocations: [],
          schedules: [
            {
              itinerary_id: itinerary.id.to_s, eta: origin_layover.eta.iso8601(3), etd: origin_layover.eta.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', hub_route_key: [origin_hub.id, destination_hub.id].join('-'), tenant_id: tenant.id.to_s, trip_id: trip.id.to_s, origin_layover_id: origin_layover.id.to_s, destination_layover_id: destination_layover.id.to_s, total: { value: '1111.0', currency: 'EUR' }
            }
          ],
          dangerousGoods: false, documents: {},
          containers: [
            {
              id: container.id, shipment_id: shipment.id, size_class: 'fcl_20', weight_class: '14t', payload_in_kg: '10000.0', tare_weight: '1000.0', gross_weight: '11000.0', dangerous_goods: false, cargo_class: 'fcl_20', hs_codes: [], customs_text: nil, quantity: 1, unit_price: nil
            }
          ],
          cargoItems: [], customs: { import: { unknown: true }, export: { unknown: true }, total: { total: { value: 0, currency: 'EUR' } } },
          locations: {
            origin: {
              id: origin_hub.nexus_id, name: origin.name, location_type: nil, latitude: origin.latitude, longitude: origin.longitude, geocoded_address: origin.geocoded_address, street: nil, street_number: nil, zip_code: nil, city: origin.city, country: origin.country, street_address: nil, province: nil, photo: nil, premise: nil
            },
            destination: {
              id: destination.id, name: destination.name, location_type: nil, latitude: destination.latitude, longitude: destination.longitude, geocoded_address: destination.geocoded_address, street: nil, street_number: nil, zip_code: nil, city: destination.city, country: destination.country, street_address: nil, province: nil, photo: nil, premise: nil
            }
          }
        }
      end

      it 'Updates the existing shipment with information about which offer was actually chosen' do
        post subdomain_shipment_choose_offer_path(subdomain_id: 'demo', shipment_id: shipment.id), params: {
          shipment: { user_id: user.id },
          schedules: [
            {
              itinerary_id: itinerary.id, eta: origin_layover.eta.iso8601(3), etd: origin_layover.eta.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', hub_route_key: [origin_hub.id, destination_hub.id].join('-'), tenant_id: tenant.id, trip_id: trip.id, origin_layover_id: origin_layover.id, destination_layover_id: destination_layover.id,
              total: { value: '1111.0', currency: 'EUR' }
            }
          ]
        }
        expect(response).to have_http_status(:success)
        expect(json[:success]).to be_truthy
        expect(json[:data]).to deep_include(response_data)
      end
    end

    context '#subdomain_shipment_update_shipment_path' do
      let(:response_data) do
        {
          shipment:
            { total_goods_value: nil, cargo_notes: nil, direction: direction, id: shipment.id, schedule_set: schedule_set, schedules_charges: response_schedules_charges, customs: { val: '1111.0', currency: 'EUR' }, total_price: { value: '2222.0', currency: 'EUR' }, customs_credit: nil, notes: nil, planned_etd: schedule_set.last[:etd], planned_eta: schedule_set.last[:eta], status: nil, load_type: load_type, planned_pickup_date: nil, pre_carriage_distance_km: nil, on_carriage_distance_km: nil, origin_id: origin.id, destination_id: destination.id, route_id: nil, uuid: shipment.uuid, imc_reference: shipment.imc_reference, has_pre_carriage: nil, has_on_carriage: nil, haulage: nil, hs_code: [], tenant_id: tenant.id, itinerary_id: itinerary.id, trucking: { on_carriage: { truck_type: '' }, pre_carriage: { truck_type: '' } }, trip_id: nil, eori: nil, incoterm: nil, origin_hub_id: nil, destination_hub_id: nil, booking_placed_at: nil, insurance: nil, transport_category_id: nil },
          schedules: [
            {
              itinerary_id: itinerary.id.to_s, eta: origin_layover.eta.iso8601(3), etd: origin_layover.eta.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', hub_route_key: [origin_hub.id, destination_hub.id].join('-'), tenant_id: tenant.id.to_s, trip_id: trip.id.to_s, origin_layover_id: origin_layover.id.to_s, destination_layover_id: destination_layover.id.to_s, total: { value: '1111.0', currency: 'EUR' }
            }
          ], documents: [],
          containers: [
            {
              id: container.id, shipment_id: shipment.id, size_class: 'fcl_20', weight_class: '14t', payload_in_kg: '10000.0', tare_weight: '1000.0', gross_weight: '11000.0', dangerous_goods: false, cargo_class: 'fcl_20', hs_codes: [], customs_text: 'test', quantity: 1, unit_price: nil
            }
          ],
          cargoItems: [],
          locations: {
            origin: {
              id: origin_hub.nexus_id, name: origin.name, location_type: nil, latitude: origin.latitude, longitude: origin.longitude, geocoded_address: origin.geocoded_address, street: nil, street_number: nil, zip_code: nil, city: origin.city, country: origin.country, street_address: nil, province: nil, photo: nil, premise: nil
            },
            destination: {
              id: destination.id, name: destination.name, location_type: nil, latitude: destination.latitude, longitude: destination.longitude, geocoded_address: destination.geocoded_address, street: nil, street_number: nil, zip_code: nil, city: destination.city, country: destination.country, street_address: nil, province: nil, photo: nil, premise: nil
            }
          }
        }
      end

      let(:schedule_set) { [{ itinerary_id: itinerary.id.to_s, eta: origin_layover.eta.iso8601(3), etd: origin_layover.eta.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', hub_route_key: [origin_hub.id, destination_hub.id].join('-'), tenant_id: tenant.id.to_s, trip_id: trip.id.to_s, origin_layover_id: origin_layover.id.to_s, destination_layover_id: destination_layover.id.to_s, total: { value: '1111.0', currency: 'EUR' } }] }

      let(:response_schedules_charges) { { [origin_hub.id, destination_hub.id].join('-').to_sym => { trucking_on: {}, trucking_pre: {}, import: {}, export: {}, cargo: { container.id.to_s.to_sym => { total: { value: '1111.0', currency: 'EUR' }, BAS: { value: '1111.0', currency: 'EUR' } } }, total: { value: '2222.0', currency: 'EUR' } } } }

      before do
        shipment.update!(itinerary: itinerary, schedule_set: schedule_set, schedules_charges: schedules_charges, containers: [container])
      end

      it 'Sets the shipment contacts & data' do
        post subdomain_shipment_update_shipment_path(subdomain_id: 'demo', shipment_id: shipment.id), params: {
          shipment: { user_id: user.id,
                      insurance: { 1 => '' },
                      shipper: {
                        location: { city: 'Gothenburg', country: 'Sweden' },
                        contact: { companyName: 'TestCargo', firstName: 'Carl', lastName: 'Carlson', phone: '12344356443', email: 'carlson@testcargo.zz' }
                      },
                      consignee: {
                        location: { city: 'Gothenburg', country: 'Sweden' },
                        contact: { companyName: 'TestConsignee', firstName: 'Svea', lastName: 'Svenson', phone: '1232346443', email: 'svenson@testconsignee.zz' }
                      },
                      customs: { import: { unknown: true }, export: { unknown: true }, total: { val: 1111, currency: 'EUR' } },
                      hsCodes: { container.id.to_s => [{ value: '123' }] },
                      hsTexts: { container.id.to_s => 'test' } }
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
        { shipment: {
          status: "requested", id: shipment.id, load_type: load_type, direction: direction, planned_pickup_date: nil, pre_carriage_distance_km: nil, on_carriage_distance_km: nil, origin_id: origin.id, destination_id: destination.id, route_id: nil, uuid: shipment.uuid, imc_reference: shipment.imc_reference, has_pre_carriage: nil, has_on_carriage: nil, cargo_notes: nil, haulage: nil, hs_code: [], schedule_set: schedule_set, tenant_id: tenant.id, planned_eta: nil, planned_etd: nil, itinerary_id: itinerary.id, trucking: { on_carriage: { truck_type: "" }, pre_carriage: { truck_type: "" } }, customs_credit: false, total_price: nil, total_goods_value: nil, trip_id: nil, eori: nil, notes: nil, incoterm: nil, origin_hub_id: nil, destination_hub_id: nil, insurance: nil, customs: nil, transport_category_id: nil } }
      end

      let(:schedule_set) { [{ itinerary_id: itinerary.id.to_s, eta: origin_layover.eta.iso8601(3), etd: origin_layover.eta.iso8601(3), closing_date: origin_layover.closing_date.iso8601(3), mode_of_transport: 'ocean', hub_route_key: [origin_hub.id, destination_hub.id].join('-'), tenant_id: tenant.id.to_s, trip_id: trip.id.to_s, origin_layover_id: origin_layover.id.to_s, destination_layover_id: destination_layover.id.to_s, total: { value: '1111.0', currency: 'EUR' } }] }

      before do
        shipment.update!(itinerary: itinerary, schedule_set: schedule_set)
      end

      it 'Is for confirming the details of the shipment displayed on the page and finalizing the booking request.' do
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
