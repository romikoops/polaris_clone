FactoryBot.define do
  factory :charge_breakdown do
    association :shipment

    before(:create) do |charge_breakdown|
      if charge_breakdown.itinerary_id.nil?
        charge_breakdown.update!(itinerary_id: charge_breakdown.shipment.itinerary_id)
      end
    end
  end
end
