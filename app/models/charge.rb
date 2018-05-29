class Charge < ApplicationRecord
  include CurrencyTools

  belongs_to :price
  belongs_to :charge_category
  belongs_to :children_charge_category,
    foreign_key: 'children_charge_category_id', class_name: 'ChargeCategory'
  belongs_to :charge_breakdown
  belongs_to :parent, class_name: 'Charge', optional: true
  has_many :children, foreign_key: 'parent_id', class_name: 'Charge'
  before_validation :set_detail_level, on: :create

  validates :detail_level, presence: true

  def deconstruct_tree_into_schedule_charge
    return price.given_attributes if children.empty?

    children_charges = children.map do |charge|
      children_charge_category = charge.children_charge_category
      key = children_charge_category.try(:cargo_unit).try(:id) || children_charge_category.code
      [key , charge.deconstruct_tree_into_schedule_charge]
    end.to_h

    { total: price.given_attributes }.merge(children_charges)
  end

  def self.create_from_schedule_charge(
    schedule_charge,
    charge_breakdown = ChargeBreakdown.create(shipment: Shipment.first),
    charge_category  = ChargeCategory.base_node,
    parent           = nil
  )
    schedule_charge.map do |key, charge_h|
      next if %w(total value currency).include? key
      children_charge_category = ChargeCategory.find_or_create_by(name: key, code: key)
      price_h = charge_h['value'].nil? ? charge_h['total'] : charge_h
      price_h ||= {
        'value' => 0,
        'currency' => 'EUR'
      }
      price = Price.create(value: price_h['value'], currency: price_h['currency'])
      charge = Charge.create!(
        price: price, charge_breakdown: charge_breakdown,
        children_charge_category: children_charge_category, charge_category: charge_category,
        parent: parent
      )
      unless charge_h['total'].nil?
        create_from_schedule_charge(charge_h, charge_breakdown, children_charge_category, charge)
      end
      charge
    end.compact
  end

  def update_price!
    rates = get_rates(price.currency).today.merge(price.currency => 1.0)
    self.price.value = children.reduce(0) do |sum, charge|
      sum + charge.price.value / rates[charge.price.currency].to_d
    end
    self.price.save!
  end

  private

  def set_detail_level
    self.detail_level = ChargeDetailLevelCalculator.exec(self)
  end

  def update_parent
    parent.update_price!
  end
end
