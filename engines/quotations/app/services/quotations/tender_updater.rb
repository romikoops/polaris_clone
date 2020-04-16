# frozen_string_literal: true

module Quotations
  class TenderUpdater
    UneditableFee = Class.new(StandardError)

    attr_reader :tender, :line_item, :section, :value, :charge_category_id, :charge

    def initialize(tender:, line_item_id:, charge_category_id:, value:, section:)
      @tender = tender
      @line_item = Quotations::LineItem.find(line_item_id) if line_item_id.present?
      @section = section.gsub('_section', '')
      @value = value
      @charge_category_id = charge_category_id
      @charge = charge_to_edit
    end

    def perform
      raise Quotations::TenderUpdater::UneditableFee unless fee_editable?

      ActiveRecord::Base.transaction do
        update_line_items if charge.detail_level == 3

        update_charge
        update_parent(charge.parent) if charge.parent.present?
        update_tender
      end
      @charge.charge_breakdown.shipment.update(updated_at: DateTime.now)
      tender
    end

    private

    def fee_editable?
      return true if line_item.blank?
      return false if line_item.charge_category.code.match?(/\A(included|excluded|unknown)/)

      true
    end

    def update_line_items
      return if line_item.nil?

      line_item.update!(amount: amount)
    end

    def update_tender
      new_amount = if line_item.present?
                     tender.line_items
                           .inject(Money.new(0, tender.amount.currency.iso_code)) do |total, item|
                             total + item.amount
                           end
                   else
                     charge_breakdown.grand_total.edited_price.money
                   end
      tender.update!(amount: new_amount)
    end

    def update_charge
      @charge.edited_price = Legacy::Price.create(value: value, currency: charge.price.currency)
      @charge.save!
    end

    def update_parent(parent_charge)
      return true if parent_charge.blank?

      parent_charge.update_edited_price!
      update_parent(parent_charge.parent)
    end

    def charge_breakdown
      Legacy::ChargeBreakdown.find_by(tender_id: tender.id)
    end

    def charge_category_by_section
      charge_breakdown.charge_categories.find_by(code: section)
    end

    def charge_category_by_cargo
      charge_breakdown.charge_categories.find_by(code: tender.load_type, cargo_unit_id: line_item.cargo_id)
    end

    def section_charge
      charge_breakdown.charges.find_by(children_charge_category: charge_category_by_section)
    end

    def cargo_charge
      section_charge.children.find_by(children_charge_category: charge_category_by_cargo)
    end

    def line_item_charge
      cargo_charge.children.find_by(children_charge_category: line_item.charge_category)
    end

    def charge_to_edit
      return line_item_charge if line_item.present?

      charge_breakdown.charges.find_by(children_charge_category_id: charge_category_id)
    end

    def amount
      Money.new(value * 100, charge.price.currency)
    end
  end
end
