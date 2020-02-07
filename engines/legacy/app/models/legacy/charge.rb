# frozen_string_literal: true

module Legacy
  class Charge < ApplicationRecord
    self.table_name = 'charges'
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
        key = children_charge_category.try(:cargo_unit_id) || children_charge_category&.code&.downcase
        [key, charge.deconstruct_tree_into_schedule_charge]
      end

      {
        total: price.rounded_attributes,
        edited_total: edited_price.try(:rounded_attributes),
        name: children_charge_category.name
      }.merge(children_charges.to_h)
    end

    def tenant_id
      charge_breakdown.shipment.tenant_id
    end

    def update_price!
      rates = Legacy::CurrencyTools.new.get_rates(price.currency, tenant_id).today.merge(price.currency => 1.0)
      price.value = children.reduce(0) do |sum, charge|
        delta = charge.price.value.nil? ? 0 : charge.price.value / rates[charge.price.currency].to_d
        sum + delta
      end

      price.save!
    end

    def update_edited_price!
      self.edited_price = Price.new(currency: price.currency) if edited_price.nil?
      rates = Legacy::CurrencyTools.new.get_rates(edited_price.currency, tenant_id).today.merge(edited_price.currency => 1.0)
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

      Pricings::Breakdown.find_by(charge_id: id)&.update(charge_id: charge.id)

      children.each do |child|
        child.dup_tree(charge_breakdown: charge_breakdown, parent: charge)
      end
    end

    private

    def set_detail_level
      number = 0
      self.detail_level = Legacy::ChargeDetailLevelCalculator.exec(self)
    end
  end
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint           not null, primary key
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  charge_breakdown_id         :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  edited_price_id             :integer
#  parent_id                   :integer
#  price_id                    :integer
#  sandbox_id                  :uuid
#
# Indexes
#
#  index_charges_on_sandbox_id  (sandbox_id)
#
