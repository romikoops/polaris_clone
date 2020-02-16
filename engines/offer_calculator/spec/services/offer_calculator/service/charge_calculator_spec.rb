# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::ChargeCalculator do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:cargo_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:fcl_20_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_20', load_type: 'container')
  end
  let(:fcl_40_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_40', load_type: 'container')
  end
  let(:fcl_40_hq_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_40_hq', load_type: 'container')
  end
  let(:vehicle) do
    FactoryBot.create(:legacy_vehicle,
                      transport_categories: [
                        fcl_20_transport_category,
                        fcl_40_transport_category,
                        fcl_40_hq_transport_category,
                        cargo_transport_category
                      ],
                      tenant_vehicles: [tenant_vehicle1, tenant_vehicle2])
  end
  let(:tenant_vehicle1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'express') }
  let(:trip1) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary1, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle1)
  end
  let(:trip2) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary2, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle2)
  end

  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}) }
  let!(:tenants_user) do
    Tenants::User.find_by(legacy_id: user.id).tap do |tapped_user|
      tapped_user.company = FactoryBot.create(:tenants_company)
    end
  end
  let(:group) do
    FactoryBot.create(:tenants_group, tenant: tenants_tenant).tap do |group|
      FactoryBot.create(:tenants_membership, member: tenants_user, group: group)
    end
  end
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let(:hub) { itinerary1.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary1.hubs.find_by(name: 'Shanghai Port') }
  let(:common_trucking) { FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, location: trucking_location) }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:cargo_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: load_type,
                      direction: direction,
                      user: user,
                      has_pre_carriage: true,
                      tenant: tenant,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Time.zone.today + 4.days,
                      cargo_items: [cargo_item])
  end
  let(:agg_cargo_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: load_type,
                      direction: direction,
                      user: user,
                      has_pre_carriage: true,
                      tenant: tenant,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Time.zone.today + 4.days,
                      aggregated_cargo: FactoryBot.build(:legacy_aggregated_cargo))
  end
  let(:container_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'container',
                      direction: direction,
                      has_pre_carriage: true,
                      user: user,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'chassis',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Time.zone.today + 4.days,
                      tenant: tenant,
                      containers: containers)
  end

  let(:itinerary1) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, tenant: tenant) }
  let(:itinerary2) { FactoryBot.create(:legacy_itinerary, :shanghai_gothenburg, tenant: tenant) }
  let(:cargo_item) { FactoryBot.create(:legacy_cargo_item) }
  let(:schedules) do
    [
      OfferCalculator::Schedule.from_trip(trip1),
      OfferCalculator::Schedule.from_trip(trip2)
    ]
  end
  let(:containers) do
    [
      FactoryBot.build(:fcl_20_container),
      FactoryBot.build(:fcl_40_container),
      FactoryBot.build(:fcl_40_hq_container)
    ]
  end

  let!(:cargo_charge_category) { FactoryBot.create(:cargo_charge_category, tenant: tenant) }
  let!(:export_charge_category) { FactoryBot.create(:export_charge_category, tenant: tenant) }
  let!(:isps_charge_category) { FactoryBot.create(:legacy_charge_categories, code: 'isps', name: 'isps', tenant: tenant) }
  let(:lcl_local_charge_fees) { FactoryBot.build(:lcl_local_charge_fees_hash) }
  let(:fcl_local_charge_fees) { FactoryBot.build(:fcl_local_charge_fees_hash) }
  let(:lcl_trucking_data) { FactoryBot.build(:lcl_trucking_data, hub: hub) }
  let(:fcl_trucking_data) { FactoryBot.build(:all_fcl_trucking_data, hub: hub) }

  before do
    stub_request(:get, 'http://data.fixer.io/latest?access_key=&base=EUR')
      .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26 } }.to_json, headers: {})
    %w[ocean air rail truck trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
    FactoryBot.create(:legacy_charge_categories, code: 'qdf', name: 'qdf', tenant: tenant)
    FactoryBot.create(:legacy_charge_categories, code: 'adi', name: 'adi', tenant: tenant)
    FactoryBot.create(:legacy_charge_categories, code: 'eca', name: 'eca', tenant: tenant)
    FactoryBot.create(:legacy_charge_categories, code: 'fill', name: 'fill', tenant: tenant)
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'lcl',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle1,
                      fees: lcl_local_charge_fees,
                      effective_date: Time.zone.today,
                      expiration_date: Time.zone.today + 3.months)
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: destination_hub,
                      mode_of_transport: 'ocean',
                      load_type: 'lcl',
                      direction: 'import',
                      tenant_vehicle: tenant_vehicle1,
                      fees: lcl_local_charge_fees,
                      effective_date: Time.zone.today,
                      expiration_date: Time.zone.today + 3.months)
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'fcl_20',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle1,
                      fees: fcl_local_charge_fees,
                      effective_date: Time.zone.today,
                      expiration_date: Time.zone.today + 3.months)
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'fcl_40',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle1,
                      fees: fcl_local_charge_fees,
                      effective_date: Time.zone.today,
                      expiration_date: Time.zone.today + 3.months)
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'fcl_40_hq',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle1,
                      fees: fcl_local_charge_fees,
                      effective_date: Time.zone.today,
                      expiration_date: Time.zone.today + 3.months)
  end

  describe '.perform', :vcr do
    let(:target_shipment) { cargo_shipment }
    let(:target_trucking_data) { lcl_trucking_data }
    let(:metadata_list) { [] }
    let(:klass) do
      described_class.new(
        shipment: target_shipment,
        user: user,
        data: target_data,
        trucking_data: target_trucking_data,
        sandbox: nil,
        metadata_list: metadata_list
      )
    end
    let(:results) { klass.perform }

    context 'when legacy' do
      let(:target_data) { legacy_lcl_data }
      let!(:pricing_one) do
        FactoryBot.create(:legacy_lcl_pricing,
                          itinerary: itinerary1,
                          tenant_vehicle: tenant_vehicle1,
                          transport_category: cargo_transport_category)
      end
      let!(:pricing_fcl_20) do
        FactoryBot.create(:legacy_fcl_20_pricing,
                          itinerary: itinerary1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle1,
                          transport_category: fcl_20_transport_category)
      end
      let!(:pricing_fcl_40) do
        FactoryBot.create(:legacy_fcl_40_pricing,
                          itinerary: itinerary1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle1,
                          transport_category: fcl_40_transport_category)
      end
      let!(:pricing_fcl_40_hq) do
        FactoryBot.create(:legacy_fcl_40_hq_pricing,
                          itinerary: itinerary1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle1,
                          transport_category: fcl_40_hq_transport_category)
      end
      let(:legacy_lcl_data) do
        {
          pricings_by_cargo_class: {
            'lcl' => pricing_one.as_json
          },
          schedules: schedules
        }
      end
      let(:legacy_fcl_data) do
        {
          pricings_by_cargo_class: {
            'fcl_20' => pricing_fcl_20.as_json,
            'fcl_40' => pricing_fcl_40.as_json,
            'fcl_40_hq' => pricing_fcl_40_hq.as_json
          },
          schedules: schedules
        }
      end

      context 'when standard lcl' do
        it 'returns an object with calculated totals and schedules for lcl' do
          aggregate_failures do
            expect(results.count).to eq(1)
            expect(results.first.keys).to match_array(%i[total schedules metadata])
            expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 357.38)
          end
        end
      end

      context 'when lcl w/ mandatory charges' do
        before do
          hub.update(mandatory_charge_id: mandatory_charge.id)
        end

        let(:target_trucking_data) { {} }
        let(:target_shipment) do
          cargo_shipment.update(trucking: {})
          cargo_shipment
        end

        let(:mandatory_charge) { FactoryBot.create(:legacy_mandatory_charge, export_charges: true) }

        it 'returns an object with calculated totals and schedules for lcl w/ mandatory charges' do
          aggregate_failures do
            expect(results.count).to eq(1)
            expect(results.first.keys).to match_array(%i[total schedules metadata])
            expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 276.63)
          end
        end
      end

      context 'with aggregated cargo' do
        let(:target_shipment) { agg_cargo_shipment }

        it 'returns an object with calculated totals and schedules for aggregated cargo' do
          aggregate_failures do
            expect(results.count).to eq(1)
            expect(results.first.keys).to match_array(%i[total schedules metadata])
            expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 277.62)
          end
        end
      end

      context 'with fcl cargo classes' do
        let(:target_shipment) { container_shipment }
        let(:target_data) { legacy_fcl_data }

        it 'returns an object with calculated totals and schedules for fcl cargo classes' do
          aggregate_failures do
            expect(results.count).to eq(1)
            expect(results.first.keys).to match_array(%i[total schedules metadata])
            expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 1506.98)
          end
        end
      end

      context 'when lcl w/ backend consolidation' do
        before do
          FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { consolidation: { cargo: { backend: true } } })
        end

        it 'returns an object with calculated totals and schedules for lcl w/ backend consolidation' do
          aggregate_failures do
            expect(results.count).to eq(1)
            expect(results.first.keys).to match_array(%i[total schedules metadata])
            expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 357.38)
          end
        end
      end
    end

    context 'with base pricing' do
      let(:target_data) { lcl_data }
      let(:pricing_one) do
        FactoryBot.create(:lcl_pricing,
                          itinerary: itinerary1,
                          tenant_vehicle: tenant_vehicle1,
                          tenant: tenant)
      end
      let(:pricing_fcl_20) do
        FactoryBot.create(:fcl_20_pricing,
                          itinerary: itinerary1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle1)
      end
      let(:pricing_fcl_40) do
        FactoryBot.create(:fcl_40_pricing,
                          itinerary: itinerary1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle1)
      end
      let(:pricing_fcl_40_hq) do
        FactoryBot.create(:fcl_40_hq_pricing,
                          itinerary: itinerary1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle1)
      end
      let(:lcl_data) do
        {
          pricings_by_cargo_class: {
            'lcl' => pricing_one.as_json
          },
          schedules: schedules
        }
      end
      let(:fcl_data) do
        {
          pricings_by_cargo_class: {
            'fcl_20' => pricing_fcl_20.as_json,
            'fcl_40' => pricing_fcl_40.as_json,
            'fcl_40_hq' => pricing_fcl_40_hq.as_json
          },
          schedules: schedules
        }
      end
      let(:margin_target) { group }
      let(:trucking_metadata_list) do
        [
          {
            fees: {
              trucking_lcl: {
                breakdowns: [
                  {
                    adjusted_rate: {
                      'kg' => [
                        { 'rate' => { 'base' => 1.0, 'value' => 68.41, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '50.0', 'min_kg' => '0.0', 'min_value' => 0.0 },
                        { 'rate' => { 'base' => 1.0, 'value' => 70.81, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '80.0', 'min_kg' => '51.0', 'min_value' => 0.0 }
                      ]
                    }
                  },
                  {
                    margin_id: '5d13222b-fe4d-4393-962a-631b0504e618',
                    margin_value: 0.1e0,
                    operator: '%',
                    margin_target_type: margin_target.class.to_s,
                    margin_target_id: margin_target.id,
                    margin_target_name: margin_target&.name,
                    adjusted_rate: {
                      'kg' =>
                      [{ 'rate' => { 'base' => 1.0, 'value' => 68.41, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '50.0', 'min_kg' => '0.0', 'min_value' => 0.0 },
                       { 'rate' => { 'base' => 1.0, 'value' => 70.81, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '80.0', 'min_kg' => '51.0', 'min_value' => 0.0 }]
                    }
                  }
                ]
              }
            }
          }
        ]
      end
      let(:quote_charge_breakdown) { current_results.first[:total].charge_breakdown }
      let(:cargo_charge) { quote_charge_breakdown.charges.find_by(children_charge_category: cargo_charge_category) }
      let(:export_charge) { quote_charge_breakdown.charges.find_by(children_charge_category: export_charge_category) }
      let(:export_cargo_ids) { export_charge.children.map(&:children_charge_category).pluck(:cargo_unit_id).uniq }
      let(:freight_cargo_ids) { cargo_charge.children.map(&:children_charge_category).pluck(:cargo_unit_id).uniq }

      before do
        FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true })
      end

      context 'when lcl' do
        let!(:current_results) { results }

        it 'returns an object with calculated totals and schedules for lcl' do
          aggregate_failures do
            expect(current_results.count).to eq(1)
            expect(current_results.first.keys).to match_array(%i[total schedules metadata])
            expect(current_results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 596.51)
          end
        end

        it 'calulates the export charges correctly' do
          aggregate_failures do
            expect(export_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 505.76)
            expect(export_cargo_ids).to match_array(target_shipment.cargo_units.ids | [nil])
          end
        end

        it 'calulates the freight charges correctly' do
          aggregate_failures do
            expect(quote_charge_breakdown.charges.find_by(children_charge_category: cargo_charge_category).price.rounded_attributes).to eq(currency: 'EUR', value: 10)
            expect(freight_cargo_ids).to match_array(target_shipment.cargo_units.ids)
          end
        end
      end

      context 'when fcl' do
        let(:target_data) { fcl_data }
        let(:target_shipment) { container_shipment }
        let(:target_trucking_data) { fcl_trucking_data }
        let!(:current_results) { results }

        it 'returns an object with calculated totals and schedules for fcl cargo classes' do
          aggregate_failures do
            expect(current_results.count).to eq(1)
            expect(current_results.first.keys).to match_array(%i[total schedules metadata])
            expect(current_results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 2611.23)
          end
        end

        it 'calulates the export charges correctly' do
          aggregate_failures do
            expect(export_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 426.23)
            expect(export_cargo_ids).to match_array(target_shipment.cargo_units.ids | [nil])
          end
        end

        it 'calulates the freight charges correctly' do
          aggregate_failures do
            expect(cargo_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 1000)
            expect(freight_cargo_ids).to match_array(target_shipment.cargo_units.ids)
          end
        end
      end

      context 'with aggregated cargo' do
        let(:target_shipment) { agg_cargo_shipment }
        let!(:current_results) { results }

        it 'returns an object with calculated totals and schedules for aggregated cargo' do
          aggregate_failures do
            expect(current_results.count).to eq(1)
            expect(current_results.first.keys).to match_array(%i[total schedules metadata])
            expect(current_results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 277.62)
          end
        end

        it 'calulates the export charges correctly' do
          aggregate_failures do
            expect(export_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 171.87)
            expect(export_cargo_ids).to eq([target_shipment.aggregated_cargo.id, nil])
          end
        end

        it 'calulates the freight charges correctly' do
          aggregate_failures do
            expect(cargo_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 25)
            expect(freight_cargo_ids).to eq([target_shipment.aggregated_cargo.id])
          end
        end
      end

      context 'with relative margins' do
        before do
          FactoryBot.create(:export_margin, origin_hub_id: hub.id, applicable: tenants_user, tenant: tenants_tenant)
        end

        let(:metadata_list) { trucking_metadata_list }
        let!(:current_results) { results }

        it 'returns an object with two quotes with subtotals and grand totals w/ margins' do
          aggregate_failures do
            expect(current_results.count).to eq(1)
            expect(current_results.first.keys).to match_array(%i[total schedules metadata])
            expect(current_results.first[:metadata]).to be_a(Pricings::Metadatum)
            expect(current_results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 647.09)
          end
        end

        it 'calulates the export charges correctly' do
          aggregate_failures do
            expect(export_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 556.34)
            expect(export_cargo_ids).to match_array(target_shipment.cargo_units.ids | [nil])
          end
        end

        it 'calulates the freight charges correctly' do
          aggregate_failures do
            expect(cargo_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 10)
            expect(freight_cargo_ids).to match_array(target_shipment.cargo_units.ids)
          end
        end
      end

      context 'with absolute margins' do
        before do
          FactoryBot.create(:export_margin,
                            origin_hub_id: hub.id,
                            applicable: tenants_user,
                            tenant: tenants_tenant,
                            value: 0,
                            operator: '%').tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail,
                              margin: tapped_margin,
                              value: 50,
                              operator: '&',
                              charge_category: isps_charge_category)
          end
        end

        let(:metadata_list) { trucking_metadata_list }
        let(:target_data) { fcl_data }
        let(:target_shipment) { container_shipment }
        let(:target_trucking_data) { fcl_trucking_data }
        let!(:current_results) { results }

        it 'returns an object with two quotes with subtotals and grand totals w/ margins' do
          aggregate_failures do
            expect(current_results.count).to eq(1)
            expect(current_results.first.keys).to match_array(%i[total schedules metadata])
            expect(current_results.first[:metadata]).to be_a(Pricings::Metadatum)
            expect(current_results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 2811.23)
          end
        end

        it 'calulates the export charges correctly' do
          aggregate_failures do
            expect(export_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 626.23)
            expect(export_cargo_ids).to match_array(target_shipment.cargo_units.ids | [nil])
          end
        end

        it 'calulates the freight charges correctly' do
          aggregate_failures do
            expect(cargo_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 1000)
            expect(freight_cargo_ids).to match_array(target_shipment.cargo_units.ids)
          end
        end
      end

      context 'with total margins' do
        before do
          FactoryBot.create(:export_margin,
                            origin_hub_id: hub.id,
                            applicable: tenants_user,
                            tenant: tenants_tenant,
                            value: 0,
                            operator: '%').tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail,
                              margin: tapped_margin,
                              value: 100,
                              operator: '+',
                              charge_category: isps_charge_category)
          end
        end

        let(:metadata_list) { trucking_metadata_list }
        let(:target_data) { fcl_data }
        let(:target_shipment) { container_shipment }
        let(:target_trucking_data) { fcl_trucking_data }
        let!(:current_results) { results }

        it 'returns an object with two quotes with subtotals and grand totals w/ margins' do
          aggregate_failures do
            expect(current_results.count).to eq(1)
            expect(current_results.first.keys).to match_array(%i[total schedules metadata])
            expect(current_results.first[:metadata]).to be_a(Pricings::Metadatum)
            expect(current_results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 3011.23)
          end
        end

        it 'calulates the export charges correctly' do
          aggregate_failures do
            expect(export_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 826.23)
            expect(export_cargo_ids).to match_array(target_shipment.cargo_units.ids | [nil])
          end
        end

        it 'calulates the freight charges correctly' do
          aggregate_failures do
            expect(cargo_charge.price.rounded_attributes).to eq(currency: 'EUR', value: 1000)
            expect(freight_cargo_ids).to match_array(target_shipment.cargo_units.ids)
          end
        end
      end
    end
  end
end
