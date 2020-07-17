# frozen_string_literal: true

FactoryBot.define do
  factory :manipulator_breakdown, class: "Pricings::ManipulatorBreakdown" do
    skip_create
    source { nil }
    delta { 0 }
    result { {} }
    charge_category { nil }

    initialize_with do
      Pricings::ManipulatorBreakdown.new(
        source: source,
        delta: source&.value,
        data: result,
        charge_category: charge_category
      )
    end
  end
end
