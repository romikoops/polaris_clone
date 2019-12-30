# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculatorService::ChargeCalculator do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:day_0) { Date.parse('30/11/2019') }
  let(:day_5) { Date.parse('05/12/2019') }
  let(:day_10) { Date.parse('10/12/2019') }
  let(:day_15) { Date.parse('15/12/2019') }
  let(:day_20) { Date.parse('20/12/2019') }
  let(:day_25) { Date.parse('25/12/2019') }
  let(:day_30) { Date.parse('30/12/2019') }
  let(:day_31) { Date.parse('31/12/2019') }
  let(:day_35) { Date.parse('05/01/2020') }
  let(:day_40) { Date.parse('10/01/2020') }
  let(:day_45) { Date.parse('15/01/2020') }

  let(:trips) do
    (1...5).map do |num|
      build(:trip,
            load_type: 'cargo_item',
            start_date: day_0 + num.days,
            end_date: day_0 + (num + 30).days)
    end
  end
  let(:schedules) do
    trips.map { |trip| Legacy::Schedule.from_trip(trip) }.sort_by(&:etd)
  end
  let(:lcl_pricing) { create(:legacy_pricing, tenant: tenant) }

  let(:import_shipment) { build(:shipment, direction: 'import', user: user, tenant: tenant) }
  let(:data) do
    {
      schedules: schedules,
      pricings_by_cargo_class: {
        lcl: lcl_pricing.as_json
      }
    }
  end
  let(:calculator) {
    described_class.new(data: data,
                        trucking_data: {},
                        shipment: import_shipment,
                        user: user,
                        sandbox: nil)
  }

  describe '.sort_by_local_charge_periods', :vcr do
    before do
      Timecop.freeze(Time.local(2019, 11, 30))
    end

    after do
      Timecop.return
    end

    context 'when validity logic is vatos' do
      let!(:scope) { create(:tenants_scope, target: tenants_user, content: { validity_logic: 'vatos' }) }
      let(:all_schedules_covered_periods) {
        { import: { { effective_date: day_0, expiration_date: day_5 } =>
            [{ 'total' => { value: 1000, currency: 'USD' } }] },
          export: { { effective_date: day_0, expiration_date: day_5 } =>
            [{ 'total' => { value: 5000, currency: 'USD' } }] } }
      }

      it 'groups schedules by charges periods' do
        schedules_by_charges = calculator.send(:sort_by_local_charge_periods, all_schedules_covered_periods)
        expected_period_key = { import_key: { effective_date: day_0, expiration_date: day_5 },
                                export_key: { effective_date: day_0, expiration_date: day_5 } }

        schedules.map(&:etd).each do |etd|
          expect(etd).to be_between(day_0, day_5)
        end

        expect(schedules_by_charges.keys.count).to eql 1
        expect(schedules_by_charges.keys.first).to match(expected_period_key)
        expect(schedules_by_charges[expected_period_key][:schedules]).to match schedules
      end
    end

    context 'when validity logic is vatoa' do
      let!(:scope) { create(:tenants_scope, target: tenants_user, content: { validity_logic: 'vatoa' }) }
      let(:all_schedules_covered_periods) {
        { import: { { effective_date: day_30, expiration_date: day_35 } =>
            [{ 'total' => { value: 1000, currency: 'USD' } }] },
          export: { { effective_date: day_30, expiration_date: day_35 } =>
            [{ 'total' => { value: 5000, currency: 'USD' } }] } }
      }

      it 'groups schedules by charges periods' do
        schedules_by_charges = calculator.send(:sort_by_local_charge_periods, all_schedules_covered_periods)
        expected_period_key = { import_key: { effective_date: day_30, expiration_date: day_35 },
                                export_key: { effective_date: day_30, expiration_date: day_35 } }

        schedules.map(&:eta).each do |eta|
          expect(eta).to be_between(day_30, day_35)
        end

        expect(schedules_by_charges.keys.count).to eql 1
        expect(schedules_by_charges.keys.first).to eql(expected_period_key)
        expect(schedules_by_charges[expected_period_key][:schedules]).to match schedules
      end
    end

    context 'when multiple periods' do
      let!(:scope) { create(:tenants_scope, target: tenants_user, content: { validity_logic: 'vatos' }) }

      let(:multiple_periods) {
        { import: {
          { effective_date: day_0, expiration_date: day_10 } =>
            [{ 'total' => { value: 1000, currency: 'USD' } }],
          { effective_date: day_10, expiration_date: day_20 } =>
            [{ 'total' => { value: 1000, currency: 'USD' } }],
          { effective_date: day_20, expiration_date: day_31 } =>
            [{ 'total' => { value: 1000, currency: 'USD' } }],
          { effective_date: day_31, expiration_date: day_35 } =>
            [{ 'total' => { value: 1000, currency: 'USD' } }],
          { effective_date: day_35, expiration_date: day_40 } =>
            [{ 'total' => { value: 1000, currency: 'USD' } }]
        },
          export: {
            { effective_date: day_0, expiration_date: day_5 } =>
              [{ 'total' => { value: 5000, currency: 'USD' } }],
            { effective_date: day_5, expiration_date: day_15 } =>
              [{ 'total' => { value: 5000, currency: 'USD' } }],
            { effective_date: day_15, expiration_date: day_31 } =>
              [{ 'total' => { value: 5000, currency: 'USD' } }],
            { effective_date: day_31, expiration_date: day_35 } =>
              [{ 'total' => { value: 1000, currency: 'USD' } }],
            { effective_date: day_40, expiration_date: day_45 } =>
              [{ 'total' => { value: 1000, currency: 'USD' } }]
          } }
      }

      let(:trips) do
        (1...45).step(4).map do |day_num|
          build(:trip,
                load_type: 'cargo_item',
                start_date: day_0 + day_num.days,
                end_date: day_0 + (day_num + 30).days)
        end
      end
      let(:schedules) do
        trips.map { |trip| Legacy::Schedule.from_trip(trip) }.sort_by(&:etd)
      end

      let(:calculator) {
        described_class.new(data: { schedules: schedules },
                            trucking_data: {},
                            shipment: import_shipment,
                            user: user,
                            sandbox: nil)
      }

      it 'groups schedules by charges periods' do
        schedules_by_charges = calculator.send(:sort_by_local_charge_periods, multiple_periods)
        expected_period_groups = [{ import_key: { effective_date: day_0, expiration_date: day_10 }, export_key: { effective_date: day_0, expiration_date: day_5 } },
                                  { import_key: { effective_date: day_0, expiration_date: day_10 }, export_key: nil },
                                  { import_key: { effective_date: day_0, expiration_date: day_10 }, export_key: { effective_date: day_5, expiration_date: day_15 } },
                                  { import_key: { effective_date: day_10, expiration_date: day_20 }, export_key: { effective_date: day_5, expiration_date: day_15 } },
                                  { import_key: { effective_date: day_10, expiration_date: day_20 }, export_key: { effective_date: day_15, expiration_date: day_31 } },
                                  { import_key: { effective_date: day_20, expiration_date: day_31 }, export_key: { effective_date: day_15, expiration_date: day_31 } },
                                  { import_key: { effective_date: day_31, expiration_date: day_35 }, export_key: { effective_date: day_31, expiration_date: day_35 } },
                                  { import_key: { effective_date: day_35, expiration_date: day_40 }, export_key: nil },
                                  { import_key: nil, export_key: nil }]

        expect(schedules_by_charges.keys.count).to eql 9
        expect(schedules_by_charges.values.pluck(:schedules).map(&:count).sum).to eql schedules.count
        expect(schedules_by_charges.keys).to match expected_period_groups
        expect(schedules_by_charges.dig(expected_period_groups[0], :schedules)).to match(schedules.select { |sched| (day_0...day_5).cover? sched.etd })
        expect(schedules_by_charges.dig(expected_period_groups[1], :schedules)).to match(schedules.select { |sched| sched.etd == day_5 })
        expect(schedules_by_charges.dig(expected_period_groups[2], :schedules)).to match(schedules.select { |sched| sched.etd > day_5 && sched.etd < day_10 })
        expect(schedules_by_charges.dig(expected_period_groups[3], :schedules)).to match(schedules.select { |sched| (day_10...day_15).cover? sched.etd })
        expect(schedules_by_charges.dig(expected_period_groups[4], :schedules)).to match(schedules.select { |sched| (day_15...day_20).cover? sched.etd })
        expect(schedules_by_charges.dig(expected_period_groups[5], :schedules)).to match(schedules.select { |sched| (day_20...day_31).cover? sched.etd })
        expect(schedules_by_charges.dig(expected_period_groups[6], :schedules)).to match(schedules.select { |sched| (day_31...day_35).cover? sched.etd })
        expect(schedules_by_charges.dig(expected_period_groups[7], :schedules)).to match(schedules.select { |sched| (day_35...day_40).cover? sched.etd })
        expect(schedules_by_charges.dig(expected_period_groups[8], :schedules)).to match(schedules.select { |sched| sched.etd == day_40 })
      end
    end
  end

  describe '.valid_until' do
    it 'returns the earliest of the expiry dates w/o local charges' do
      periods = {}
      valid_until_date = calculator.send(:valid_until, periods)
      expect(valid_until_date).to eq(lcl_pricing.expiration_date.beginning_of_day)
    end

    it 'returns the earliest of the expiry dates w local charges' do
      export_key = { expiration_date: 4.days.from_now.end_of_day }.with_indifferent_access
      periods = {
        export: {
          export_key => {}
        }
      }
      valid_until_date = calculator.send(:valid_until, periods)
      expect(valid_until_date).to eq(4.days.from_now.beginning_of_day)
    end
  end
end
