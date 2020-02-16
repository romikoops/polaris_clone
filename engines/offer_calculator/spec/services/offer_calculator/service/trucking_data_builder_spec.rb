# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::TruckingDataBuilder do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:membership) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, tenant: tenant) }
  let(:hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let!(:common_trucking) { FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, location: trucking_location) }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      tenant: tenant,
                      user: user,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Date.today + 4.days,
                      cargo_items: [FactoryBot.create(:legacy_cargo_item)],
                      itinerary: itinerary,
                      has_pre_carriage: true)
  end
  let(:address) { FactoryBot.create(:legacy_address) }
  let(:service) { described_class.new(shipment: shipment, sandbox: nil) }
  let(:hub_result) { { origin: [hub] } }

  context 'legacy' do
    before do
      allow(service).to receive(:calc_distance).and_return(10)
      FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, user_id: user.id, location: trucking_location)
    end

    describe '.perform' do
      it 'finds the trucking pricings and calculates the rates' do
        results = service.perform(hub_result)
        aggregate_failures do
          expect(results.keys).to match_array(%i[metadata trucking_pricings selected_fees])
          expect(results.dig(:trucking_pricings, 'pre').keys).to match_array([hub.id])
        end
      end
    end
  end

  before do
    FactoryBot.create(:puf_charge, tenant: tenant)
    FactoryBot.create(:trucking_on_margin, default_for: 'trucking', tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
    FactoryBot.create(:trucking_pre_margin, default_for: 'trucking', tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
  end

  Timecop.freeze(Time.utc(2020, 1, 1, 0, 0, 0)) do
    before(:each) do
      stub_request(:get, 'https://maps.googleapis.com/maps/api/directions/xml?alternative=false&departure_time=1576800000&destination=57.694253,11.854048&key=&language=en&mode=driving&origin=57.694253,11.854048&traffic_model=pessimistic')
        .to_return(status: 200, body: FactoryBot.create(:google_directions_response), headers: {})
    end

    context 'base_pricing' do
      before do
        FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
        FactoryBot.create(:tenants_membership, member: tenants_user, group: group)
        FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, group_id: group.id, location: trucking_location)
      end

      let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
      let!(:group) { FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'Test') }

      describe '.perform (base pricing)' do
        it 'finds the trucking pricings and calculates the rates' do
          allow(service).to receive(:calc_distance).and_return(10)

          results = service.perform(hub_result)
          expect(results.keys).to match_array(%i[metadata trucking_pricings selected_fees])
          expect(results.dig(:trucking_pricings, 'pre').keys).to match_array([hub.id])
        end

        context 'with mocked google directions' do
          before do
            directions_service = double('OfferCalculator::GoogleDirections')
            allow_any_instance_of(OfferCalculator::GoogleDirections).to receive(:initialize).and_return(directions_service)
          end

          it 'return the distance in km from google directions' do
            allow_any_instance_of(OfferCalculator::GoogleDirections).to receive(:distance_in_km).and_return(1000)

            results = service.perform(hub_result)
            expect(results.keys).to match_array(%i[metadata trucking_pricings selected_fees])
          end

          it 'return 0 if from google directions cant find the distance' do
            allow_any_instance_of(OfferCalculator::GoogleDirections).to receive(:distance_in_km).and_return(nil)

            results = service.perform(hub_result)
            expect(results.keys).to match_array(%i[metadata trucking_pricings selected_fees])
          end
        end
      end
    end

    context 'errors' do
      let(:error_shipment) do
        FactoryBot.create(:legacy_shipment,
                          load_type: 'cargo_item',
                          tenant: tenant,
                          user: user,
                          desired_start_date: Date.today + 4.days,
                          trucking: {
                            'pre_carriage': {
                              'address_id': address.id,
                              'truck_type': 'default',
                              'trucking_time_in_seconds': 145_688
                            }
                          },
                          itinerary: itinerary,
                          cargo_items: [
                            FactoryBot.build(:legacy_cargo_item,
                                             dimension_x: 240,
                                             dimension_y: 160,
                                             dimension_z: 230,
                                             payload_in_kg: 1000,
                                             quantity: 2)
                          ],
                          has_pre_carriage: true)
      end
      let(:error_service) { described_class.new(shipment: error_shipment, sandbox: nil) }
      let!(:scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true }) }

      before do
        allow(error_service).to receive(:calc_distance).and_return(10)
      end

      describe 'load meterage exceeded' do
        it 'raises the LoadMeterageExceeded Error when ldm is exceeded' do
          scope.update(content: scope.content.merge(hard_trucking_limit: true))
          expect { error_service.perform(hub_result) }.to raise_error(OfferCalculator::TruckingTools::LoadMeterageExceeded)
        end
      end

      describe 'it raises missing trucking data' do
        let(:wrong_address) { FactoryBot.create(:felixstowe_address) }

        context 'wrong address' do
          before do
            error_shipment.trucking['pre_carriage']['address_id'] = wrong_address.id
            error_shipment.save!
          end

          it 'raises the MissingTruckingData Error when no data is found' do
            expect { error_service.perform(hub_result) }.to raise_error(OfferCalculator::Calculator::MissingTruckingData)
          end
        end

        it 'raises the MissingTruckingData Error when a calculation error occurs' do
          common_trucking.update(rates: { 'kg' => {} })
          expect { error_service.perform(hub_result) }.to raise_error(OfferCalculator::Calculator::MissingTruckingData)
        end

        it 'raises the MissingTruckingData Error when a calculation error occurs' do
          allow(error_service).to receive(:calc_distance).and_return('not_a_distance')
          expect { error_service.perform(hub_result) }.to raise_error(OfferCalculator::Calculator::MissingTruckingData)
        end
      end
    end
  end
end
