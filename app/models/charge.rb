class Charge < ApplicationRecord
  has_one :price
  belongs_to :charge_category
  belongs_to :children_charge_category,
    foreign_key: :children_charge_category_id, class_name: "ChargeCategory"
  belongs_to :charge_breakdown
  belongs_to :parent, class_name: "ChargeBreakdown", optional: true
  has_many :children, foreign_key: :parent_id, class_name: "Charge"
  before_validation :set_detail_level, on: :create

  validates :detail_level, presence: true

  def deconstruct_tree_into_schedule_charge
    children_charges = children.map do |charge|
      children_charge_category = charge.children_charge_category
      key = children_charge_category.try(:cargo_unit).try(:id) || children_charge_category.code
      [key , charge.to_schedule_charge]
    end.to_h

    { total: price }.merge(children_charges)
  end

  private

  def set_detail_level
    self.detail_level = ChargeDetailLevelCalculator.exec(self)
  end
end
