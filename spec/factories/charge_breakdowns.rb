FactoryBot.define do
  factory :charge_breakdown do
    association :shipment

    before(:create) do |charge_breakdown|
      if charge_breakdown.trip_id.nil?
        charge_breakdown.update!(trip_id: charge_breakdown.shipment.trip_id)
      end

      if charge_breakdown.charges.empty?
        charge_breakdown.charges << build(
          :charge,
          charge_breakdown:         charge_breakdown,
          charge_category:          ChargeCategory.grand_total,
          children_charge_category: build(:charge_category, name: :cargo),
          parent: build(
            :charge,
            charge_breakdown:         charge_breakdown,
            charge_category:          ChargeCategory.base_node,
            children_charge_category: ChargeCategory.grand_total
          )
        )
      end
    end
  end
end
