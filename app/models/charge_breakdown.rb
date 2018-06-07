# frozen_string_literal: true

class ChargeBreakdown < ApplicationRecord
  belongs_to :shipment
  belongs_to :itinerary

  validates :itinerary_id, uniqueness: {
    scope:   :shipment_id,
    message: lambda { |obj, _|
      itinerary_info = "#{obj.itinerary_id} (#{obj.itinerary.name})"
      "#{itinerary_info} is already taken for shipment_id #{obj.shipment_id}"
    }
  }

  has_many :charges, dependent: :destroy do
    def from_category(charge_category)
      where(charge_category: ChargeCategory.where(code: charge_category))
    end
  end

  has_many :charge_categories, through: :charges do
    def detail(level=0)
      where('charges.detail_level': level).uniq
    end
  end

  scope :selected, -> {
    joins(:shipment).where("charge_breakdowns.itinerary_id = shipments.itinerary_id")
  }

  def charge(charge_category)
    charges.where(children_charge_category: ChargeCategory.where(code: charge_category)).first
  end

  def grand_total
    charge("grand_total")
  end

  def to_schedule_charges
    hub_route_key = "#{itinerary.first_stop.hub.id}-#{itinerary.last_stop.hub.id}"
    { hub_route_key => grand_total.deconstruct_tree_into_schedule_charge }.deep_stringify_keys
  end
end
