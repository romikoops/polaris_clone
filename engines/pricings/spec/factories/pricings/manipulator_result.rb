# frozen_string_literal: true

FactoryBot.define do
  factory :manipulator_result, class: "Pricings::ManipulatorResult" do
    skip_create
    original { {} }
    result { {} }
    breakdowns { [] }
    transient do
      margins { [] }
    end

    initialize_with do
      if original.is_a? Trucking::Trucking
        result["effective_date"] = Time.zone.today.to_s
        result["expiration_date"] = (Time.zone.today + 3.months).to_s
      end
      if original.is_a? Pricings::Pricing
        original.fees.each do |fee|
          breakdowns << FactoryBot.build(:manipulator_breakdown,
            source: nil,
            delta: 0,
            data: fee.fee_data,
            charge_category: fee.charge_category)
          margins.each do |margin|
            breakdowns << FactoryBot.build(:manipulator_breakdown,
              source: margin,
              data: fee.fee_data,
              charge_category: fee.charge_category)
          end
        end
      end

      Pricings::ManipulatorResult.new(
        result: result,
        original: original,
        breakdowns: breakdowns,
        flat_margins: []
      )
    end
  end
end
