# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::TruckingDataBuilder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:membership) { FactoryBot.create(:groups_membership, member: user, group: group) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, organization: organization) }
  let(:hub) { itinerary.hubs.find_by(name: 'Gothenburg') }
  let!(:common_trucking) { FactoryBot.create(:trucking_trucking, organization: organization, hub: hub, location: trucking_location) }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      organization: organization,
                      user: user,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Time.zone.today + 4.days,
                      cargo_items: [FactoryBot.create(:legacy_cargo_item)],
                      itinerary: itinerary,
                      has_pre_carriage: true)
  end
  let(:service) { described_class.new(shipment: shipment, sandbox: nil) }
  let(:hub_result) { { origin: [hub] } }

  before do
    ::Organizations.current_id = organization.id

    FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization)
    FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization)

    FactoryBot.create(:lcl_pre_carriage_availability, hub: hub, query_type: :zipcode)
    stub_request(:get, 'https://maps.googleapis.com/maps/api/directions/xml?alternative=false&departure_time=1576800000&destination=57.694253,11.854048&key=&language=en&mode=driving&origin=57.694253,11.854048&traffic_model=pessimistic')
      .to_return(status: 200, body: FactoryBot.create(:google_directions_response), headers: {})
    FactoryBot.create(:puf_charge, organization: organization)
    FactoryBot.create(:trucking_on_margin, default_for: 'trucking', organization: organization, applicable: organization, value: 0)
    FactoryBot.create(:trucking_pre_margin, default_for: 'trucking', organization: organization, applicable: organization, value: 0)
  end

  context 'with legacy' do
    before do
      allow(service).to receive(:calc_distance).and_return(10)
      FactoryBot.create(:trucking_trucking, organization: organization, hub: hub, user_id: user.id, location: trucking_location)
    end

    describe '.perform' do
      it 'finds the trucking pricings and calculates the rates' do
        results = service.perform(hubs: hub_result)
        aggregate_failures do
          expect(results.keys).to match_array(%i[metadata trucking_pricings selected_fees])
          expect(results.dig(:trucking_pricings, 'pre').keys).to match_array([hub.id])
        end
      end
    end
  end

  Timecop.freeze(Time.utc(2020, 1, 1, 0, 0, 0)) do
    context 'with base_pricing' do
      before do
        FactoryBot.create(:organizations_scope, target: organization, content: { base_pricing: true })
        FactoryBot.create(:groups_membership, member: user, group: group)
        FactoryBot.create(:trucking_trucking, organization: organization, hub: hub, group_id: group.id, location: trucking_location)
      end

      let(:results) { service.perform(hubs: hub_result) }
      let!(:group) { FactoryBot.create(:groups_group, organization: organization, name: 'Test') }

      describe '.perform (base pricing)' do
        it 'finds the trucking pricings and calculates the rates' do
          allow(service).to receive(:calc_distance).and_return(10)

          aggregate_failures do
            expect(results.keys).to match_array(%i[metadata trucking_pricings selected_fees])
            expect(results.dig(:trucking_pricings, 'pre').keys).to match_array([hub.id])
          end
        end
      end
    end

    context 'with errors' do
      let(:error_shipment) do
        FactoryBot.create(:legacy_shipment,
                          load_type: 'cargo_item',
                          organization: organization,
                          user: user,
                          desired_start_date: Time.zone.today + 4.days,
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
                                             width: 240,
                                             length: 160,
                                             height: 230,
                                             payload_in_kg: 1000,
                                             quantity: 2)
                          ],
                          has_pre_carriage: true)
      end
      let(:error_service) { described_class.new(shipment: error_shipment, sandbox: nil) }
      let!(:scope) { FactoryBot.create(:organizations_scope, target: organization, content: { base_pricing: true }) }

      before do
        allow(error_service).to receive(:calc_distance).and_return(10)
      end

      describe 'load meterage exceeded' do
        it 'raises the LoadMeterageExceeded Error when ldm is exceeded' do
          scope.update(content: scope.content.merge(hard_trucking_limit: true))
          expect { error_service.perform(hubs: hub_result) }.to raise_error(OfferCalculator::TruckingTools::LoadMeterageExceeded)
        end
      end

      describe 'it raises missing trucking data' do
        let(:wrong_address) { FactoryBot.create(:felixstowe_address) }

        context 'with an invalid address' do
          before do
            error_shipment.trucking['pre_carriage']['address_id'] = wrong_address.id
            error_shipment.save!
          end

          it 'raises the MissingTruckingData Error when no data is found' do
            expect { error_service.perform(hubs: hub_result) }.to raise_error(OfferCalculator::Calculator::MissingTruckingData)
          end
        end

        it 'raises the MissingTruckingData Error when a calculation error occurs' do
          common_trucking.update(rates: { 'kg' => {} })
          expect { error_service.perform(hubs: hub_result) }.to raise_error(OfferCalculator::Calculator::MissingTruckingData)
        end

        it 'raises the MissingTruckingData Error when distance is not returned' do
          allow(error_service).to receive(:calc_distance).and_return('not_a_distance')
          expect { error_service.perform(hubs: hub_result) }.to raise_error(OfferCalculator::Calculator::MissingTruckingData)
        end
      end
    end
  end
end
