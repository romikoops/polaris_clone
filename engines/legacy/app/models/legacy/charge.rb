# frozen_string_literal: true

module Legacy
  class Charge < ApplicationRecord
    self.table_name = 'charges'
    has_paper_trail
    belongs_to :price
    belongs_to :edited_price, class_name: 'Legacy::Price', optional: true
    belongs_to :charge_category
    belongs_to :children_charge_category,
               foreign_key: 'children_charge_category_id', class_name: 'Legacy::ChargeCategory'
    belongs_to :charge_breakdown, optional: true
    belongs_to :parent, class_name: 'Legacy::Charge', optional: true
    has_many :children, foreign_key: 'parent_id', class_name: 'Legacy::Charge', dependent: :destroy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    before_validation :set_detail_level, on: :create

    validates :detail_level, presence: true

    def deconstruct_tree_into_schedule_charge(args,
                                              sub_total_charge: false)

      return price.given_attributes.merge(name: children_charge_category.name) if children.empty?

      children_charges = children.map do |charge|
        children_charge_category = charge.children_charge_category
        key = children_charge_category.try(:cargo_unit_id) || children_charge_category&.code&.downcase
        [key, charge.deconstruct_tree_into_schedule_charge(args,
                                                           sub_total_charge: true)]
      end.to_h

      hidden_grand_total = args.fetch(:hidden_grand_total, false)
      hidden_sub_total = args.fetch(:hidden_sub_total, false)
      hide_converted_grand_total = args.fetch(:hide_converted_grand_total, false)
      guest = args.fetch(:guest, false)
      should_hide_grand_total = ((hidden_grand_total || guest) && charge_category.code == 'base_node') ||
                                (hide_converted_grand_total && charge_breakdown.currency_count > 1)

      should_hide = should_hide_grand_total || (guest || (hidden_sub_total && sub_total_charge))
      total = should_hide ? nil : price.rounded_attributes

      {
        total: total,
        edited_total: edited_price.try(:rounded_attributes),
        name: children_charge_category.name
      }.merge(children_charges)
    end

    def tenant_id
      charge_breakdown.shipment.tenant_id
    end

    def update_price!
      price.money = children.reduce(Money.new(0, price.currency)) do |sum, charge|
        sum + charge.price.money
      end
      price.save
    end

    def update_edited_price!
      self.edited_price = Price.new(currency: price.currency) if edited_price.nil?
      new_total = children.reduce(Money.new(0, price.currency)) do |sum, charge|
        sum + (charge.edited_price || charge.price).money
      end

      edited_price.money = new_total
      edited_price.save
      save
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
#  index_charges_on_charge_category_id           (charge_category_id)
#  index_charges_on_children_charge_category_id  (children_charge_category_id)
#  index_charges_on_sandbox_id                   (sandbox_id)
#
