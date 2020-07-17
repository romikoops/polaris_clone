# frozen_string_literal: true

FactoryBot.define do
  factory :calculators_charge, class: "OfferCalculator::Service::Calculators::Charge" do
    skip_create
    value {}
    fee {}
    fee_component { fee.components.first }

    initialize_with do
      OfferCalculator::Service::Calculators::Charge.new(attributes)
    end
  end
end
