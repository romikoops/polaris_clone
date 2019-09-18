# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'Pricing .insert' do
  it 'returns correct stats and creates correct data' do
    stats = described_class.insert(options)
    itinerary = Itinerary.last
    expect(itinerary.slice(:name, :mode_of_transport).values).to eq(['Gothenburg - Shanghai', 'ocean'])
    expect(Stop.pluck(:itinerary_id).uniq.first).to eq(itinerary.id)
    pricings = Pricing.all
    expect(stats).to eq(expected_stats)
    dates = pricings.pluck(:effective_date, :expiration_date)
    expect(dates.sort).to eq(expected_dates.sort)
    pricing_details_values =
      PricingDetail.where(priceable: pricings)
                   .pluck(:rate,
                          :rate_basis,
                          :min,
                          :shipping_type,
                          :range,
                          :currency_name,
                          :priceable_type)
    expect(pricing_details_values - pricing_details_values).to be_empty
  end
end

RSpec.describe ExcelDataServices::DatabaseInserters::Pricing do
  let(:tenant) { create(:tenant) }
  let!(:hubs) do
    [create(:hub, tenant: tenant, name: 'Gothenburg Port', hub_type: 'ocean'),
     create(:hub, tenant: tenant, name: 'Shanghai Port', hub_type: 'ocean')]
  end
  let(:itineraries) do
    [create(:itinerary, tenant: tenant)]
  end
  let!(:stops) do
    [create(:stop, hub: hubs.first, index: 0, itinerary: itineraries.first),
     create(:stop, hub: hubs.second, index: 1, itinerary: itineraries.first)]
  end
  let!(:transport_categories) do
    [create(:transport_category, load_type: 'cargo_item', cargo_class: 'lcl')] +
      Container::CARGO_CLASSES.map { |cc| create(:transport_category, load_type: 'container', cargo_class: cc) }
  end
  let(:tenant_vehicle) do
    create(:tenant_vehicle, tenant: tenant)
  end
  let(:options) { { tenant: tenant, data: input_data, options: {} } }
  let!(:static_expected_dates) { [[Time.zone.parse('2018-03-15').beginning_of_day, Time.zone.parse('2019-03-17').end_of_day.change(usec: 0)]] * 15 }
  describe '.insert' do
    let(:input_data) { build(:excel_data_restructured_correct_pricings_one_fee_col_and_ranges) }

    context 'with overlap case: no_old_record' do
      let!(:expected_stats) do
        { :"legacy/itineraries" => { number_created: 0, number_deleted: 0, number_updated: 0 },
          :"legacy/pricing_details" => { number_created: 18, number_deleted: 1, number_updated: 0 },
          :"legacy/pricings" => { number_created: 17, number_deleted: 1, number_updated: 0 },
          :"legacy/stops" => { number_created: 0, number_deleted: 0, number_updated: 0 } }
      end
      let!(:expected_dates) do
        [
          [Time.zone.parse('2018-03-11').beginning_of_day, Time.zone.parse('2019-03-17').end_of_day.change(usec: 0)]
        ] + static_expected_dates
      end
      let!(:expected_pricing_details_values) do
        [
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing']
        ]
      end

      include_examples 'Pricing .insert'
    end

    context 'with overlap case: new_starts_after_old_and_extends_beyond' do
      let!(:pricings) do
        [
          create(:pricing,
                 wm_rate: 0.1e4,
                 effective_date: Date.parse('Thu, 1 Mar 2018').beginning_of_day,
                 expiration_date: Date.parse('Sun, 16 Mar 2019').end_of_day.change(usec: 0),
                 tenant: tenant,
                 transport_category: TransportCategory.find_by(cargo_class: 'fcl_20'),
                 user_id: nil,
                 itinerary: itineraries.first,
                 tenant_vehicle: tenant_vehicle)
        ]
      end
      let!(:expected_stats) do
        { :"legacy/itineraries" => { number_created: 0, number_deleted: 0, number_updated: 0 },
          :"legacy/pricing_details" => { number_created: 18, number_deleted: 1, number_updated: 0 },
          :"legacy/pricings" => { number_created: 17, number_deleted: 1, number_updated: 1 },
          :"legacy/stops" => { number_created: 0, number_deleted: 0, number_updated: 0 } }
      end
      let!(:expected_dates) do
        [
          [Time.zone.parse('2018-03-11').beginning_of_day, Time.zone.parse('2019-03-17').end_of_day.change(usec: 0)],
          [Time.zone.parse('2018-03-01').beginning_of_day, Time.zone.parse('2018-03-14').end_of_day.change(usec: 0)]
        ] + static_expected_dates
      end
      let!(:expected_pricing_details_values) do
        [
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing']
        ]
      end

      include_examples 'Pricing .insert'
    end

    context 'with overlap case: no_overlap' do
      let!(:pricings) do
        [
          create(:pricing,
                 wm_rate: 0.1e4,
                 effective_date: Date.parse('Thu, 20 Jun 2019').beginning_of_day,
                 expiration_date: Date.parse('Sun, 20 Jul 2019').end_of_day.change(usec: 0),
                 tenant: tenant,
                 transport_category: TransportCategory.find_by(cargo_class: 'lcl'),
                 user_id: nil,
                 itinerary: itineraries.first,
                 tenant_vehicle: tenant_vehicle,
                 pricing_detail_attrs: { rate_basis: 'PER_WM', rate: 11 })
        ]
      end
      let!(:expected_stats) do
        { :"legacy/itineraries" => { number_created: 0, number_deleted: 0, number_updated: 0 },
          :"legacy/pricing_details" => { number_created: 18, number_deleted: 1, number_updated: 0 },
          :"legacy/pricings" => { number_created: 17, number_deleted: 1, number_updated: 0 },
          :"legacy/stops" => { number_created: 0, number_deleted: 0, number_updated: 0 } }
      end
      let!(:expected_dates) do
        [
          [Time.zone.parse('2019-06-20').beginning_of_day, Time.zone.parse('2019-07-20').end_of_day.change(usec: 0)],
          [Time.zone.parse('2018-03-11').beginning_of_day, Time.zone.parse('2019-03-17').end_of_day.change(usec: 0)]
        ] + static_expected_dates
      end
      let!(:expected_pricing_details_values) do
        [
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing']
        ]
      end

      include_examples 'Pricing .insert'
    end

    context 'with overlap case: new_is_covered_by_old' do
      let!(:pricings) do
        [
          create(:pricing,
                 wm_rate: 0.1e4,
                 effective_date: Date.parse('Thu, 01 Jun 2017').beginning_of_day,
                 expiration_date: Date.parse('Sun, 20 Jul 2019').end_of_day.change(usec: 0),
                 tenant: tenant,
                 transport_category: TransportCategory.find_by(cargo_class: 'lcl'),
                 user_id: nil,
                 itinerary: itineraries.first,
                 tenant_vehicle: tenant_vehicle,
                 pricing_detail_attrs: { rate_basis: 'PER_WM', rate: 11 })
        ]
      end
      let!(:expected_stats) do
        { :"legacy/itineraries" => { number_created: 0, number_deleted: 0, number_updated: 0 },
          :"legacy/pricing_details" => { number_created: 18, number_deleted: 1, number_updated: 0 },
          :"legacy/pricings" => { number_created: 18, number_deleted: 1, number_updated: 2 },
          :"legacy/stops" => { number_created: 0, number_deleted: 0, number_updated: 0 } }
      end
      let!(:expected_dates) do
        [
          [Time.zone.parse('2019-03-18').beginning_of_day, Time.zone.parse('2019-07-20').end_of_day.change(usec: 0)],
          [Time.zone.parse('2018-03-11').beginning_of_day, Time.zone.parse('2019-03-17').end_of_day.change(usec: 0)],
          [Time.zone.parse('2017-06-01').beginning_of_day, Time.zone.parse('2018-03-10').end_of_day.change(usec: 0)]
        ] + static_expected_dates
      end
      let!(:expected_pricing_details_values) do
        [
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing']
        ]
      end

      include_examples 'Pricing .insert'
    end

    context 'with overlap case: new_starts_before_old_and_stops_before_old_ends' do
      let!(:pricings) do
        [
          create(:pricing,
                 wm_rate: 0.1e4,
                 effective_date: Date.parse('Thu, 16 Mar 2018').beginning_of_day,
                 expiration_date: Date.parse('Sun, 20 Mar 2019').end_of_day.change(usec: 0),
                 tenant: tenant,
                 transport_category: TransportCategory.find_by(cargo_class: 'lcl'),
                 user_id: nil,
                 itinerary: itineraries.first,
                 tenant_vehicle: tenant_vehicle,
                 pricing_detail_attrs: { rate_basis: 'PER_WM', rate: 11 })
        ]
      end
      let!(:expected_stats) do
        { :"legacy/itineraries" => { number_created: 0, number_deleted: 0, number_updated: 0 },
          :"legacy/pricing_details" => { number_created: 18, number_deleted: 1, number_updated: 0 },
          :"legacy/pricings" => { number_created: 17, number_deleted: 1, number_updated: 1 },
          :"legacy/stops" => { number_created: 0, number_deleted: 0, number_updated: 0 } }
      end
      let!(:expected_dates) do
        [
          [Time.zone.parse('2019-03-18').beginning_of_day, Time.zone.parse('2019-03-20').end_of_day.change(usec: 0)],
          [Time.zone.parse('2018-03-11').beginning_of_day, Time.zone.parse('2019-03-17').end_of_day.change(usec: 0)]
        ] + static_expected_dates
      end
      let!(:expected_pricing_details_values) do
        [
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.2e2, 'PER_WM', 0.2e2, 'HAS', [{ 'max' => 100, 'min' => 0, 'rate' => 20 }, { 'max' => 500, 'min' => 101, 'rate' => 25 }], 'USD', 'Pricing'],
          [0.17e2, 'PER_WM', 0.17e2, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing'],
          [0.1234e4, 'PER_CONTAINER', 0.1234e4, 'BAS', [], 'USD', 'Pricing']
        ]
      end

      include_examples 'Pricing .insert'
    end
  end
end
