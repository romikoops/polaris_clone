class ChargeBreakdown < ApplicationRecord
  belongs_to :shipments
  has_many :charges do
    def from_category(charge_category)
      where(charge_category: charge_category)
    end
  end

  has_many :charge_categories, through: :charges do
    def detail(level = 0)
      where(detail_level: level)
    end
  end

  def charge(category)
    charges.where(children_charge_category: category).first
  end

  def grand_total
    charge('grand_total')
  end

  def to_schedule_charge(itinerary)
    hub_route_key = "#{itinerary.first_stop.hub}-#{itinerary.last_stop.hub}"
    { hub_route_key => grand_total.deconstruct_tree_into_schedule_charge }
  end
end
