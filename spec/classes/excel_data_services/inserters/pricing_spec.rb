# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'Pricing .insert' do
  it 'returns correct stats and creates correct data' do
    base_pricing = scope.content['base_pricing']
    stats = described_class.insert(options)
    itinerary = Itinerary.last
    expect(itinerary.slice(:name, :mode_of_transport).values).to eq(['Gothenburg - Shanghai', 'ocean'])
    expect(itinerary.map_data[0][:origin]).to eq itinerary.stops[0].hub.lng_lat_array
    expect(itinerary.map_data[0][:destination]).to eq itinerary.stops[1].hub.lng_lat_array
    expect(Stop.pluck(:itinerary_id).uniq.first).to eq(itinerary.id)
    pricings = base_pricing ? ::Pricings::Pricing.all : ::Pricing.all
    expect(stats).to eq(expected_stats)
    dates = pricings.pluck(:effective_date, :expiration_date)
    expect(dates).to match_array(expected_dates)
    pricing_details = base_pricing ? ::Pricings::Fee.where(pricing: pricings) : ::PricingDetail.where(priceable: pricings)
    pricing_details_values =
      if base_pricing
        pricing_details.joins(:rate_basis).pluck(
          :rate,
          'pricings_rate_bases.external_code',
          :min,
          :range,
          :currency_name
        )
      else
        pricing_details.pluck(
          :rate,
          :rate_basis,
          :min,
          :range,
          :currency_name
        )
      end
    expect(pricing_details_values).to match_array(expected_pricing_details_values)
  end
end

RSpec.describe ExcelDataServices::Inserters::Pricing do
  let(:tenant) { create(:tenant) }
  let(:hubs) do
    [
      create(:hub,
             tenant: tenant,
             name: 'Gothenburg Port',
             hub_type: 'ocean',
             nexus: create(:nexus, name: 'Gothenburg')),
      create(:hub,
             tenant: tenant,
             name: 'Shanghai Port',
             hub_type: 'ocean',
             nexus: create(:nexus, name: 'Shanghai'))
    ]
  end
  let!(:itineraries) do
    [
      create(:itinerary, tenant: tenant,
                         stops: [
                           build(:stop, itinerary_id: nil, index: 0, hub: hubs.first),
                           build(:stop, itinerary_id: nil, index: 1, hub: hubs.second)
                         ])
    ]
  end
  let!(:transport_categories) do
    [create(:transport_category, load_type: 'cargo_item', cargo_class: 'lcl')] +
      Container::CARGO_CLASSES.map { |cc| create(:transport_category, load_type: 'container', cargo_class: cc) }
  end
  let(:tenant_vehicle) do
    create(:tenant_vehicle, tenant: tenant)
  end
  let(:options) { { tenant: tenant, data: input_data, options: {} } }

  describe '.insert' do
    let(:input_data) { build(:excel_data_restructured_correct_pricings_one_fee_col_and_ranges) }

    context 'with overlap case: no_old_record' do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 15, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 16), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD']
        ]
      end

      context 'with scope attribute \'base_pricing\' set to >>> true <<<' do
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => true })
        end
        let!(:expected_stats) do
          { "legacy/stops": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "legacy/itineraries": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "pricings/pricings": { number_created: 21, number_deleted: 0, number_updated: 3 },
            "pricings/fees": { number_created: 28, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end

      context 'with scope attribute \'base_pricing\' set to >>> false <<<' do
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => false })
        end
        let!(:expected_stats) do
          { "legacy/stops": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "legacy/itineraries": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "legacy/pricings": { number_created: 21, number_updated: 3, number_deleted: 0 },
            "legacy/pricing_details": { number_created: 28, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end
    end

    context 'with overlap case: new_starts_after_old_and_stops_at_or_after_old' do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 1), DateTime.new(2018, 3, 14, 23, 59, 59)],
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 15, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 16), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.1111e4, 'PER_CONTAINER', nil, [], 'EUR'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD']
        ]
      end

      context 'with scope attribute \'base_pricing\' set to >>> true <<<' do
        let!(:pricings) do
          [
            create(:pricings_pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2018, 3, 1),
                   expiration_date: DateTime.new(2019, 3, 16, 23, 59, 59),
                   tenant: tenant,
                   load_type: 'container',
                   cargo_class: 'fcl_20',
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   fee_attrs: { rate: 1111, rate_basis: :per_container, min: nil })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => true })
        end
        let!(:expected_stats) do
          { "legacy/stops": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "legacy/itineraries": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "pricings/pricings": { number_created: 21, number_deleted: 0, number_updated: 4 },
            "pricings/fees": { number_created: 28, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end

      context 'with scope attribute \'base_pricing\' set to >>> false <<<' do
        let!(:pricings) do
          [
            create(:pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2018, 3, 1),
                   expiration_date: DateTime.new(2019, 3, 16, 23, 59, 59),
                   tenant: tenant,
                   transport_category: TransportCategory.find_by(cargo_class: 'fcl_20'),
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   pricing_detail_attrs: { rate: 1111, rate_basis: 'PER_CONTAINER' })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => false })
        end
        let!(:expected_stats) do
          { "legacy/itineraries": { number_created: 0, number_deleted: 0, number_updated: 0 },
            "legacy/pricings": { number_created: 21, number_deleted: 0, number_updated: 4 },
            "legacy/pricing_details": { number_created: 28, number_deleted: 0, number_updated: 0 },
            "legacy/stops": { number_created: 0, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end
    end

    context 'with overlap case: no_overlap' do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 15, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 16), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)],
          [DateTime.new(2019, 6, 20), DateTime.new(2019, 7, 20, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.11e2, 'PER_WM', nil, [], 'EUR'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD']
        ]
      end

      context 'with scope attribute \'base_pricing\' set to >>> true <<<' do
        let!(:pricings) do
          [
            create(:pricings_pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2019, 6, 20),
                   expiration_date: DateTime.new(2019, 7, 20, 23, 59, 59),
                   tenant: tenant,
                   cargo_class: 'lcl',
                   load_type: 'cargo_item',
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   fee_attrs: { rate_basis: :per_wm_rate_basis, rate: 11, min: nil })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => true })
        end
        let!(:expected_stats) do
          { "legacy/stops": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "legacy/itineraries": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "pricings/pricings": { number_created: 21, number_deleted: 0, number_updated: 3 },
            "pricings/fees": { number_created: 28, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end

      context 'with scope attribute \'base_pricing\' set to >>> false <<<' do
        let!(:pricings) do
          [
            create(:pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2019, 6, 20),
                   expiration_date: DateTime.new(2019, 7, 20, 23, 59, 59),
                   tenant: tenant,
                   transport_category: TransportCategory.find_by(cargo_class: 'lcl'),
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   pricing_detail_attrs: { rate_basis: 'PER_WM', rate: 11 })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => false })
        end
        let!(:expected_stats) do
          { "legacy/itineraries": { number_created: 0, number_deleted: 0, number_updated: 0 },
            "legacy/pricings": { number_created: 21, number_deleted: 0, number_updated: 3 },
            "legacy/pricing_details": { number_created: 28, number_deleted: 0, number_updated: 0 },
            "legacy/stops": { number_created: 0, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end
    end

    context 'with overlap case: new_is_covered_by_old' do
      let!(:expected_dates) do
        [
          [DateTime.new(2017, 6, 1), DateTime.new(2018, 3, 10, 23, 59, 59)],
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 15, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 16), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)],
          [DateTime.new(2019, 3, 29), DateTime.new(2019, 7, 20, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.11e2, 'PER_WM', nil, [], 'EUR'],
          [0.11e2, 'PER_WM', nil, [], 'EUR'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD']
        ]
      end

      context 'with scope attribute \'base_pricing\' set to >>> true <<<' do
        let!(:pricings) do
          [
            create(:pricings_pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2017, 6, 1),
                   expiration_date: DateTime.new(2019, 7, 20, 23, 59, 59),
                   tenant: tenant,
                   cargo_class: 'lcl',
                   load_type: 'cargo_item',
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   fee_attrs: { rate_basis: :per_wm_rate_basis, rate: 11, min: nil })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => true })
        end
        let!(:expected_stats) do
          { "legacy/stops": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "legacy/itineraries": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "pricings/pricings": { number_created: 22, number_deleted: 0, number_updated: 8 },
            "pricings/fees": { number_created: 28, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end

      context 'with scope attribute \'base_pricing\' set to >>> false <<<' do
        let!(:pricings) do
          [
            create(:pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2017, 6, 1),
                   expiration_date: DateTime.new(2019, 7, 20, 23, 59, 59),
                   tenant: tenant,
                   transport_category: TransportCategory.find_by(cargo_class: 'lcl'),
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   pricing_detail_attrs: { rate_basis: 'PER_WM', rate: 11 })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => false })
        end
        let!(:expected_stats) do
          { "legacy/itineraries": { number_created: 0, number_deleted: 0, number_updated: 0 },
            "legacy/pricings": { number_created: 22, number_deleted: 0, number_updated: 8 },
            "legacy/pricing_details": { number_created: 28, number_deleted: 0, number_updated: 0 },
            "legacy/stops": { number_created: 0, number_deleted: 0, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end
    end

    context 'with overlap case: new_starts_before_old_and_stops_before_old_ends' do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 15, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 16), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.17e2, 'PER_WM', 0.17e2, [], 'USD'],
          [0.5e3, 'PER_WM', 0.5e3, [], 'USD'],
          [0.2e2, 'PER_WM', 0.2e2, [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD'],
          [0.2e1, 'PER_WM', 0.2e1, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, [], 'USD']
        ]
      end

      context 'with scope attribute \'base_pricing\' set to >>> true <<<' do
        let!(:pricings) do
          [
            create(:pricings_pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2018, 3, 16),
                   expiration_date: DateTime.new(2019, 3, 20, 23, 59, 59),
                   tenant: tenant,
                   cargo_class: 'lcl',
                   load_type: 'cargo_item',
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   fee_attrs: { rate_basis: :per_wm_rate_basis, rate: 11, min: nil })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => true })
        end
        let!(:expected_stats) do
          { "legacy/stops": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "legacy/itineraries": { number_created: 0, number_updated: 0, number_deleted: 0 },
            "pricings/pricings": { number_created: 21, number_deleted: 1, number_updated: 6 },
            "pricings/fees": { number_created: 28, number_deleted: 1, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end

      context 'with scope attribute \'base_pricing\' set to >>> false <<<' do
        let!(:pricings) do
          [
            create(:pricing,
                   wm_rate: 0.1e4,
                   effective_date: DateTime.new(2018, 3, 16),
                   expiration_date: DateTime.new(2019, 3, 20, 23, 59, 59),
                   tenant: tenant,
                   transport_category: TransportCategory.find_by(cargo_class: 'lcl'),
                   user_id: nil,
                   itinerary: itineraries.first,
                   tenant_vehicle: tenant_vehicle,
                   pricing_detail_attrs: { rate_basis: 'PER_WM', rate: 11 })
          ]
        end
        let!(:scope) do
          ::Tenants::Scope.find_or_create_by(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id),
                                             content: { 'base_pricing' => false })
        end
        let!(:expected_stats) do
          { "legacy/stops": { number_created: 0, number_deleted: 0, number_updated: 0 },
            "legacy/itineraries": { number_created: 0, number_deleted: 0, number_updated: 0 },
            "legacy/pricings": { number_created: 21, number_deleted: 1, number_updated: 6 },
            "legacy/pricing_details": { number_created: 28, number_deleted: 1, number_updated: 0 } }
        end

        include_examples 'Pricing .insert'
      end
    end
  end
end
