# frozen_string_literal: true

FactoryBot.define do
  factory :rate_charged_cargo, class: "RateExtractor::Decorators::RateChargedCargo" do
    initialize_with { new(object, context: context) }

    trait :unit do
      transient do
        object {
          FactoryBot.create(:lcl_unit,
            cargo: FactoryBot.create(:cargo_cargo,
              quotation_id: FactoryBot.create(:quotations_quotation).id))
        }
      end
    end
  end
end
