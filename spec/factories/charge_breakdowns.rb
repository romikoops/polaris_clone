FactoryBot.define do
  factory :charge_breakdown do
    association :shipment

    before(:create) do |charge_breakdown|
      if charge_breakdown.trip_id.nil?
        charge_breakdown.update!(trip_id: charge_breakdown.shipment.trip_id)
      end
    end
  end
end
