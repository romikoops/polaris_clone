# frozen_string_literal: true

FactoryBot.define do
  factory :rates_cargo, class: 'Rates::Cargo' do
    association :section, factory: :rates_section

    cargo_class { '00' }
    cargo_type { 'GP' }
    code { 'BAS' }
    operator { :min_value }

    trait :section do
      applicable_to { 1 }
    end

    trait :shipment do
      applicable_to { 2 }
    end

    trait :lcl do
      cargo_class { '00' }
      cargo_type { 'LCL' }
    end

    trait :container_20 do
      cargo_class { '22' }
    end

    trait :container_40 do
      cargo_class { '42' }
    end

    trait :container_40_hq do
      cargo_class { '45' }
    end

    trait :container_45 do
      cargo_class { 'L0' }
    end
  end
end

# == Schema Information
#
# Table name: rates_cargos
#
#  id            :uuid             not null, primary key
#  applicable_to :integer          default("self")
#  cargo_class   :integer          default("00")
#  cargo_type    :integer          default("LCL")
#  category      :integer          default(0)
#  cbm_ratio     :decimal(, )
#  code          :string
#  operator      :integer
#  order         :integer          default(0)
#  valid_at      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  section_id    :uuid
#
# Indexes
#
#  index_rates_cargos_on_cargo_class  (cargo_class)
#  index_rates_cargos_on_cargo_type   (cargo_type)
#  index_rates_cargos_on_category     (category)
#  index_rates_cargos_on_section_id   (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (section_id => rates_sections.id)
#
