FactoryBot.define do
  factory :rates_margin, class: "Rates::Margin" do
    association :organization, factory: :organizations_organization
    association :applicable_to, factory: :organizations_user
    cargo_class { "00" }
    rate_basis { :cbm }
    cargo_type { "GP" }
    amount_cents { 2500 }
    amount_currency { "USD" }
    kg_range { (0..Float::INFINITY) }
    stowage_range { (0..Float::INFINITY) }
    km_range { (0..Float::INFINITY) }
    cbm_range { (0..Float::INFINITY) }
    wm_range { (0..Float::INFINITY) }
    unit_range { (0..Float::INFINITY) }
    validity { (4.days.ago..60.days.from_now) }
    min_amount_cents { 100 }
    min_amount_currency { "USD" }
    max_amount_cents { 1_000_000 }
    max_amount_currency { "USD" }
    cbm_ratio { 1000 }

    trait :section do
      association :target, factory: :rates_section
    end

    trait :cargo do
      association :target, factory: :rates_cargo
    end

    trait :group do
      association :applicable_to, factory: :groups_group
    end

    trait :company do
      association :applicable_to, factory: :companies_company
    end

    trait :user do
      association :applicable_to, factory: :organizations_user
    end

    trait :addition do
      operator { :addition }
      amount_cents { 2500 }
      amount_currency { "USD" }
    end

    trait :percentage do
      operator { :percentage }
      percentage { 5 }
    end

    trait :lcl do
      cargo_class { "00" }
      cargo_type { "LCL" }
    end

    trait :container_20 do
      cargo_class { "22" }
    end

    trait :container_40 do
      cargo_class { "42" }
    end

    trait :container_40_hq do
      cargo_class { "45" }
    end

    trait :container_45 do
      cargo_class { "L0" }
    end

    trait :kg_basis do
      rate_basis { 4 }
      kg_range { 5..10 }
    end

    trait :stowage_basis do
      rate_basis { 5 }
      stowage_range { 5..10 }
    end

    trait :wm_basis do
      rate_basis { 1 }
      wm_range { 5..10 }
    end

    trait :max do
      max_cents { 100 }
    end

    trait :cbm_basis do
      rate_basis { 3 }
      cbm_range { 5..10 }
    end

    trait :unit_basis do
      rate_basis { 6 }
      unit_range { 5..10 }
    end

    trait :shipment_basis do
      min_amount_cents { 0 }
      max_amount_cents { 100 }
      rate_basis { :shipment }
    end

    trait :km_basis do
      rate_basis { 7 }
      km_range { (0..Float::INFINITY) }
    end

    trait :percentage_basis do
      min_amount_cents { 0 }
      max_amount_cents { 100 }
      rate_basis { :percentage }
    end
  end
end
