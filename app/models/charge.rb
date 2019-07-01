# frozen_string_literal: true

require 'bigdecimal'

class Charge < ApplicationRecord
  has_paper_trail
  belongs_to :price
  belongs_to :edited_price, class_name: 'Price', optional: true
  belongs_to :charge_category
  belongs_to :children_charge_category,
             foreign_key: 'children_charge_category_id', class_name: 'ChargeCategory'
  belongs_to :charge_breakdown, optional: true
  belongs_to :parent, class_name: 'Charge', optional: true
  has_many :children, foreign_key: 'parent_id', class_name: 'Charge', dependent: :destroy
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  before_validation :set_detail_level, on: :create

  validates :detail_level, presence: true

  def deconstruct_tree_into_schedule_charge
    return price.given_attributes.merge(name: children_charge_category.name) if children.empty?

    children_charges = children.map do |charge|
      children_charge_category = charge.children_charge_category
      key = children_charge_category.try(:cargo_unit).try(:id) || children_charge_category&.code&.downcase
      [key, charge.deconstruct_tree_into_schedule_charge]
    end.to_h

    {
      total: price.rounded_attributes,
      edited_total: edited_price.try(:rounded_attributes),
      name: children_charge_category.name
    }.merge(children_charges)
  end

  def self.create_from_schedule_charges(
    schedule_charge,
    charge_breakdown = ChargeBreakdown.create(shipment: Shipment.first),
    charge_category = ChargeCategory.base_node,
    parent = nil
  )
    schedule_charge = { 'grand_total' => schedule_charge } if parent.nil?
    schedule_charge.each do |key, charge_h|
      next if %w(total value currency).include? key

      children_charge_category = ChargeCategory.from_code(
        name: key,
        code: key.downcase,
        tenant_id: charge_breakdown.trip.itinerary.tenant_id
      )
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
      unless charge_h['total'].nil? && key != 'cargo'
        create_from_schedule_charges(charge_h, charge_breakdown, children_charge_category, charge)
      end
    end
    charge_breakdown
  end

  def tenant_id
    charge_breakdown.shipment.tenant_id
  end

  def update_price!
    rates = CurrencyTools.new.get_rates(price.currency, tenant_id).today.merge(price.currency => 1.0)
    price.value = children.reduce(0) do |sum, charge|
      price = charge.price
      delta = price.value.nil? ? 0 : price.value / rates[price.currency].to_d
      sum + delta
    end

    price.save!
  end

  def update_quote_price!(tenant_id)
    rates = CurrencyTools.new.get_rates(price.currency, tenant_id).today.merge(price.currency => 1.0)
    price.value = children.reduce(0) do |sum, charge|
      price = charge.price
      delta = price.value.nil? ? 0 : price.value / rates[price.currency].to_d
      sum + delta
    end

    price.save!
  end

  def update_edited_price!
    self.edited_price = Price.new(currency: price.currency) if edited_price.nil?
    rates = CurrencyTools.new.get_rates(edited_price.currency, tenant_id).today.merge(edited_price.currency => 1.0)
    edited_price.value = children.reduce(0) do |sum, charge|
      price = charge.edited_price || charge.price
      delta = price.value.nil? ? 0 : price.value / rates[price.currency].to_d

      sum + delta
    end

    edited_price.save!
  end

  def dup_tree(charge_breakdown:, parent: nil)
    charge = dup
    charge.update(parent: parent, charge_breakdown: charge_breakdown)

    children.each do |child|
      child.dup_tree(charge_breakdown: charge_breakdown, parent: charge)
    end
  end

  private

  def set_detail_level
    self.detail_level = ChargeDetailLevelCalculator.exec(self)
  end

  def update_parent
    parent.update_price!
  end
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint(8)        not null, primary key
#  parent_id                   :integer
#  price_id                    :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  charge_breakdown_id         :integer
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  edited_price_id             :integer
#  sandbox_id                  :uuid
#
