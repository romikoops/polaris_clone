# frozen_string_literal: true

FactoryBot.define do
  factory :charge_breakdown do
    association :shipment

    before(:create) do |charge_breakdown|
      charge_breakdown.update!(trip_id: charge_breakdown.shipment.trip_id) if charge_breakdown.trip_id.nil?

      if charge_breakdown.charges.empty?
        charge_breakdown.charges << build(
          :charge,
          charge_breakdown: charge_breakdown,
          charge_category: ChargeCategory.grand_total,
          children_charge_category: build(:charge_category, name: :cargo),
          parent: build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: ChargeCategory.base_node,
            children_charge_category: ChargeCategory.grand_total
          )
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id          :bigint(8)        not null, primary key
#  shipment_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  trip_id     :integer
#
