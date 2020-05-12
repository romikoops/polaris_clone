# frozen_string_literal: true

FactoryBot.define do
  factory :rate_extractor_cargo_rate, class: 'RateExtractor::Decorators::CargoRate' do
    initialize_with do
      instance = new(object)
      instance.targets = targets
      instance
    end

    transient do
      section { FactoryBot.create(:rates_section) }
    end

    trait :shipment_targeted_rate do
      transient do
        object { FactoryBot.create(:rates_cargo, section: section, applicable_to: :shipment) }
        targets { [FactoryBot.create(:rate_charged_cargo, :unit, context: { rate: self })] }
      end
    end

    trait :section_targeted_rate do
      transient do
        object { FactoryBot.create(:rates_cargo, section: section, applicable_to: :section) }
        targets { [FactoryBot.create(:rate_charged_cargo, :unit, context: { rate: self })] }
      end
    end

    trait :cargo_targeted_rate do
      transient do
        object { FactoryBot.create(:rates_cargo, section: section, applicable_to: :cargo) }
        targets { [FactoryBot.create(:rate_charged_cargo, :unit, context: { rate: self })] }
      end
    end

    trait :with_target do
      transient do
        cargo { nil }
      end

      targets { [FactoryBot.create(:rate_charged_cargo, object: cargo, context: { rate: self })] }
    end
  end
end

# == Schema Information
#
# Table name: rates_cargos
#
#  id            :uuid             not null, primary key
#  applicable_to :integer          default("cargo")
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
