# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_fee, class: 'Ledger::Fee' do
    transient do
      varied_dates { false }
      start { true }
      random { false }
      load_meterage_limit { nil }
      load_meterage_type { nil }
      load_meterage_ratio { nil }
      load_meterage_logic { nil }
    end

    association :rate, factory: :ledger_rate

    cargo_class { 0 }
    category { 0 }
    code { 'BAS' }
    action { 0 }
    base { 0.0000000001 }

    trait :percentage do
      code { 'BAS - section_percentage' }

      after(:build) do |fee, evaluator|
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ]
        else
          delta_hashes = [{}]
        end
        def_value = evaluator.random ? rand(5..25) : 25
        delta_hashes.map.with_index do |obj, i|
          obj[:amount_cents] = evaluator.varied_dates ? def_value * (i.zero? ? 0.95 : 1.05) : def_value
          fee.deltas << build(:percentage_delta, obj)
        end
      end
    end

    trait :section do
      applicable { 1 }
    end

    trait :shipment do
      applicable { 2 }
    end

    trait :stowage_range do
      code { 'BAS - stowage_range' }

      after(:build) do |fee, evaluator|
        base_delta_hashes = [
          { rate_basis: 1, stowage_range: (0..5), amount_cents: 1000 },
          { rate_basis: 2, stowage_range: (6..Float::INFINITY), amount_cents: 150 }
        ]

        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ].flat_map do |dates|
            base_delta_hashes.flat_map.with_index do |bf, i|
              bf[:amount_cents] *= 1.05 if i.zero?
              bf.merge(dates)
            end
          end
        else
          delta_hashes = base_delta_hashes
        end

        if evaluator.random
          delta_hashes = delta_hashes.map do |fee|
            fee[:amount_cents] = rand(1000..10_000)
            fee
          end
        end
        delta_hashes.map do |obj|
          fee.deltas << build(:stowage_delta, obj)
        end
      end
    end

    trait :kg_range do
      code { 'BAS - kg_range' }

      after(:build) do |fee, evaluator|
        base_delta_hashes = [
          { kg_range: (0..500), amount_cents: 200 },
          { kg_range: (501..1000), amount_cents: 175 },
          { kg_range: (1001..1500), amount_cents: 150 },
          { kg_range: (1501..5000), amount_cents: 100 }
        ]

        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ].flat_map do |dates|
            base_delta_hashes.flat_map.with_index do |bf, i|
              bf[:amount_cents] *= 1.05 if i.zero?
              bf.merge(dates)
            end
          end
        else
          delta_hashes = base_delta_hashes
        end
        if evaluator.random
          delta_hashes = delta_hashes.map do |delta|
            delta[:amount_cents] = rand(1000..10_000)
            delta
          end
        end

        if evaluator.load_meterage_ratio.present?
          fee.load_meterage_limit = evaluator.load_meterage_limit
          fee.load_meterage_logic = evaluator.load_meterage_logic
          fee.load_meterage_type = evaluator.load_meterage_type
          fee.load_meterage_ratio = evaluator.load_meterage_ratio
        end
        delta_hashes.map do |obj|
          fee.deltas << build(:kg_delta, obj)
        end
      end
    end

    trait :cbm_range do
      code { 'BAS - cbm_range' }
      after(:build) do |fee, evaluator|
        base_delta_hashes = [
          { cbm_range: (0..2), amount_cents: 200, rate_basis: 5 },
          { cbm_range: (2.1..3.5), amount_cents: 175, rate_basis: 5 },
          { cbm_range: (3.6..15), amount_cents: 150, rate_basis: 5 }
        ]

        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ].flat_map do |dates|
            base_delta_hashes.flat_map.with_index do |bf, i|
              bf[:amount_cents] *= 1.05 if i.zero?
              bf.merge(dates)
            end
          end
        else
          delta_hashes = base_delta_hashes
        end
        if evaluator.random
          delta_hashes = delta_hashes.map do |delta|
            delta[:amount_cents] = rand(1000..10_000)
            delta
          end
        end
        delta_hashes.map do |obj|
          fee.deltas << build(:cbm_delta, obj)
        end
      end
    end

    trait :km_range do
      code { 'BAS - km_range' }
      after(:build) do |fee, evaluator|
        base_delta_hashes = [
          { km_range: (0..500), amount_cents: 200, rate_basis: 6 },
          { km_range: (501..1000), amount_cents: 175, rate_basis: 6 },
          { km_range: (1001..1500), amount_cents: 150, rate_basis: 6 }
        ]
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days

          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ].flat_map do |dates|
            base_delta_hashes.flat_map.with_index do |bf, i|
              bf[:amount_cents] *= 1.05 if i.zero?
              bf.merge(dates)
            end
          end
        else
          delta_hashes = base_delta_hashes
      end
        if evaluator.random
          delta_hashes = delta_hashes.map do |delta|
            delta[:amount_cents] = rand(1000..10_000)
            delta
          end
        end
        delta_hashes.map do |obj|
          fee.deltas << build(:km_delta, obj)
        end
      end
    end

    trait :unit_range do
      code { 'BAS - unit_range' }
      after(:build) do |fee, evaluator|
        base_delta_hashes = [
          { unit_range: (0..5), amount_cents: 200, rate_basis: 5 },
          { unit_range: (6..10), amount_cents: 175, rate_basis: 5 },
          { unit_range: (11..15), amount_cents: 150, rate_basis: 5 }
        ]
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ].flat_map do |dates|
            base_delta_hashes.flat_map.with_index do |bf, i|
              bf[:amount_cents] *= 1.05 if i.zero?
              bf.merge(dates)
            end
          end
        else
          delta_hashes = base_delta_hashes
        end
        if evaluator.random
          delta_hashes = delta_hashes.map do |delta|
            delta[:amount_cents] = rand(1000..10_000)
            delta
          end
        end
        delta_hashes.map do |obj|
          fee.deltas << build(:unit_delta, obj)
        end
      end
    end

    trait :cbm_ton do
      code { 'BAS - cbm_ton' }
      action { 2 }
      after(:build) do |fee, evaluator|
        base_delta_hashes = [
          { rate_basis: 1, amount_cents: 1000 },
          { rate_basis: 2, amount_cents: 15 }
        ]
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ].flat_map do |dates|
            base_delta_hashes.flat_map.with_index do |bf, i|
              bf[:amount_cents] *= 1.05 if i.zero?
              bf.merge(dates)
            end
          end
        else
          delta_hashes = base_delta_hashes
        end
        if evaluator.random
          delta_hashes = delta_hashes.map do |delta|
            delta[:amount_cents] = rand(1000..10_000)
            delta
          end
        end
        delta_hashes.map do |obj|
          fee.deltas << build(:ledger_deltum, obj)
        end
      end
    end

    trait :base_100 do
      base { 100 }
    end

    trait :max do
      code { 'BAS - max' }
      after(:build) do |fee, _evaluator|
        fee.deltas << build(:max_delta)
      end
    end

    trait :wm do
      code { 'BAS - wm' }
      after(:build) do |fee, evaluator|
        if evaluator.load_meterage_ratio.present?
          fee.load_meterage_limit = evaluator.load_meterage_limit
          fee.load_meterage_logic = evaluator.load_meterage_logic
          fee.load_meterage_type = evaluator.load_meterage_type
          fee.load_meterage_ratio = evaluator.load_meterage_ratio
        end
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ]
        else
          delta_hashes = [{}]
        end
        def_value = evaluator.random ? rand(2000..3000) : 2500
        delta_hashes.map.with_index do |obj, i|
          obj[:amount_cents] = def_value * (i.zero? ? 0.95 : 1.05)
          fee.deltas << build(:wm_delta, obj)
        end
      end
    end

    trait :kg do
      code { 'BAS - kg' }
      after(:build) do |fee, evaluator|
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ]
        else
          delta_hashes = [{}]
        end
        def_value = evaluator.random ? rand(2000..3000) : 2500
        delta_hashes.map.with_index do |obj, i|
          obj[:amount_cents] = def_value * (i.zero? ? 0.95 : 1.05) if evaluator.varied_dates
          fee.deltas << build(:kg_delta, obj)
        end
      end
    end

    trait :km do
      code { 'BAS - km' }
      after(:build) do |fee, evaluator|
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ]
        else
          delta_hashes = [{}]
        end
        def_value = evaluator.random ? rand(2000..3000) : 2500
        delta_hashes.map.with_index do |obj, i|
          obj[:amount_cents] = def_value * (i.zero? ? 0.95 : 1.05) if evaluator.varied_dates
          fee.deltas << build(:km_delta, obj)
        end
      end
    end

    trait :cbm do
      code { 'BAS - cbm' }
      after(:build) do |fee, evaluator|
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ]
        else
          delta_hashes = [{}]
        end
        def_value = evaluator.random ? rand(2000..3000) : 2500
        delta_hashes.map.with_index do |obj, i|
          obj[:amount_cents] = def_value * (i.zero? ? 0.95 : 1.05) if evaluator.varied_dates
          fee.deltas << build(:cbm_delta, obj)
        end
      end
    end

    trait :unit do
      code { 'BAS - unit' }
      after(:build) do |fee, evaluator|
        if evaluator.varied_dates
          date = evaluator.start ? Date.today : Date.today + 20.days
          delta_hashes = [
            { validity: ((date - 10.days)..(date + 15.days)) },
            { validity: ((date + 17.days)..(date + 40.days)) }
          ]
        else
          delta_hashes = [{}]
        end
        def_value = evaluator.random ? rand(2000..3000) : 2500
        delta_hashes.map.with_index do |obj, i|
          obj[:amount_cents] = def_value * (i.zero? ? 0.95 : 1.05) if evaluator.varied_dates
          fee.deltas << build(:unit_delta, obj)
        end
      end
    end

    trait :cargo_item do
      cargo_class { Cargo::Specification::CLASS_ENUM.key('00') }
    end

    trait :container_20 do
      cargo_class { Cargo::Specification::CLASS_ENUM.key('20') }
    end

    trait :container_40 do
      cargo_class { Cargo::Specification::CLASS_ENUM.key('40') }
    end

    trait :container_40_hq do
      cargo_class { Cargo::Specification::CLASS_ENUM.key('45') }
    end

    trait :container_45 do
      cargo_class { Cargo::Specification::CLASS_ENUM.key('L0') }
    end

    trait :carriage_range_kg do
      code { 'CARRIAGE - kg range' }
      after(:build) do |fee, evaluator|
        if evaluator.load_meterage_ratio.present?
          fee.load_meterage_limit = evaluator.load_meterage_limit
          fee.load_meterage_logic = evaluator.load_meterage_logic
          fee.load_meterage_type = evaluator.load_meterage_type
          fee.load_meterage_ratio = evaluator.load_meterage_ratio
        end
        step = 499
        current = 0
        value = evaluator.random ? rand(10_000..30_000) : 10_000
        (0..10).each do |iteration|
          step_adj = step + (iteration.zero? ? 1 : 0)
          current_adj = current + (iteration.zero? ? 0 : 1)
          weight_range = (current_adj..(current_adj + step_adj))
          fee.deltas << build(:shipment_delta,
                              kg_range: weight_range,
                              amount_cents: value - (iteration * value * 0.05))
          current = current_adj + step_adj
        end
      end
    end

    trait :carriage_range_km do
      code { 'CARRIAGE - km range' }
      after(:build) do |fee, evaluator|
        step = 499
        current = 0
        value = evaluator.random ? rand(10_000..30_000) : 10_000
        (0..10).each do |iteration|
          step_adj = step + (iteration.zero? ? 1 : 0)
          current_adj = current + (iteration.zero? ? 0 : 1)
          weight_range = (current_adj..(current_adj + step_adj))
          fee.deltas << build(:shipment_delta,
                              km_range: weight_range,
                              amount_cents: value - (iteration * value * 0.05))
          current = current_adj + step_adj
        end
      end
    end

    factory :range_kg_fee, traits: [:kg_range]
    factory :range_km_fee, traits: [:km_range]
    factory :range_unit_fee, traits: [:unit_range]
    factory :range_cbm_fee, traits: [:cbm_range]
    factory :range_stowage_fee, traits: [:stowage_range]
    factory :km_fee, traits: [:km]
    factory :unit_fee, traits: [:unit]
    factory :kg_fee, traits: [:kg]
    factory :wm_fee, traits: [:wm]
    factory :cbm_fee, traits: [:cbm]
    factory :max_shipment_fee, traits: %i(shipment max cargo_item)
    factory :section_percentage_fee, traits: %i(section percentage cargo_item)
    factory :shipment_percentage_fee, traits: %i(shipment percentage cargo_item)
    factory :x_kg_fee, traits: %i(kg base_100)
    factory :range_x_kg_fee, traits: %i(kg_range base_100)
    factory :cbm_ton_fee, traits: [:cbm_ton]
    factory :cargo_item_fee, traits: %i(wm cargo_item)
    factory :container_fee, traits: %i(unit container_20)
    factory :container_20_fee, traits: %i(unit container_20)
    factory :container_40_fee, traits: %i(unit container_40)
    factory :container_40_hq_fee, traits: %i(unit container_40_hq)
    factory :container_45_fee, traits: %i(unit container_45)
    factory :cargo_item_carriage_kg, traits: %i(carriage_range_kg cargo_item)
    factory :container_carriage_kg, traits: %i(carriage_range_kg container_20)
    factory :container_20_carriage_kg, traits: %i(carriage_range_kg container_20)
    factory :container_40_carriage_kg, traits: %i(carriage_range_kg container_40)
    factory :container_40_hq_carriage_kg, traits: %i(carriage_range_kg container_40_hq)
    factory :container_45_carriage_kg, traits: %i(carriage_range_kg container_45)
    factory :cargo_item_carriage_km, traits: %i(carriage_range_km cargo_item)
    factory :container_carriage_km, traits: %i(carriage_range_km container_20)
    factory :container_20_carriage_km, traits: %i(carriage_range_km container_20)
    factory :container_40_carriage_km, traits: %i(carriage_range_km container_40)
    factory :container_40_hq_carriage_km, traits: %i(carriage_range_km container_40_hq)
    factory :container_45_carriage_km, traits: %i(carriage_range_km container_45)
  end
end

# == Schema Information
#
# Table name: ledger_fees
#
#  id                  :uuid             not null, primary key
#  action              :integer          default("nothing")
#  applicable          :integer          default("self")
#  base                :decimal(, )      default(0.000001)
#  cargo_class         :bigint           default("00")
#  cargo_type          :bigint           default("LCL")
#  category            :integer          default(0)
#  code                :string
#  load_meterage_limit :decimal(, )      default(0.0)
#  load_meterage_logic :integer          default("regular")
#  load_meterage_ratio :decimal(, )      default(0.0)
#  load_meterage_type  :integer          default("height")
#  order               :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rate_id             :uuid
#
# Indexes
#
#  index_ledger_fees_on_cargo_class  (cargo_class)
#  index_ledger_fees_on_cargo_type   (cargo_type)
#  index_ledger_fees_on_category     (category)
#  index_ledger_fees_on_rate_id      (rate_id)
#
