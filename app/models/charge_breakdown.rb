# frozen_string_literal: true

class ChargeBreakdown < ApplicationRecord
  belongs_to :shipment
  belongs_to :trip

  validates :trip_id, uniqueness: {
    scope:   :shipment_id,
    message: lambda { |obj, _|
      trip_info = "#{obj.trip_id} (Itinerary - #{obj.trip.itinerary.name})"
      "#{trip_info} is already taken for shipment_id #{obj.shipment_id}"
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
    joins(:shipment).where("charge_breakdowns.trip_id = shipments.trip_id").first
  }

  def charge(charge_category)
    charges.where(children_charge_category: ChargeCategory.where(code: charge_category)).first
  end

  def grand_total
    charge("grand_total")
  end

  def to_nested_hash
    grand_total.deconstruct_tree_into_schedule_charge.deep_stringify_keys
  end
end
