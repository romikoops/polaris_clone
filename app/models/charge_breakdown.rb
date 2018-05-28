class ChargeBreakdown < ApplicationRecord
  belongs_to :shipment
  has_many :charges do
    def from_category(charge_category)
      where(charge_category: ChargeCategory.where(code: charge_category))
    end
  end

  has_many :charge_categories, through: :charges do
    def detail(level = 0)
      where('charges.detail_level': level).uniq
    end
  end

  def charge(charge_category)
    charges.where(children_charge_category: ChargeCategory.where(code: charge_category)).first
  end

  def grand_total
    charge('grand_total')
  end

  def to_schedule_charge(itinerary)
    hub_route_key = "#{itinerary.first_stop.hub.id}-#{itinerary.last_stop.hub.id}"
    { hub_route_key => grand_total.deconstruct_tree_into_schedule_charge }.deep_stringify_keys
  end
end
