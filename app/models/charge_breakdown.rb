class ChargeBreakdown < ApplicationRecord
  belongs_to :shipments
  has_many :charges
  has_many :charge_categories, through: :charges
  has_many :charge_subtotals

  def to_schedule_charge(itinerary)
    "#{itinerary.first_stop.hub}-#{itinerary.last_stop.hub}"


  end
end
