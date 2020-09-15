# frozen_string_literal: true

module Quotations
  class TenderUpdater
    UneditableFee = Class.new(StandardError)

    attr_reader :tender, :line_item, :section, :value, :charge_category_id

    def initialize(tender:, line_item_id:, charge_category_id:, value:, section:)
      @tender = tender
      @line_item = Quotations::LineItem.find(line_item_id) if line_item_id.present?
      @section = section.gsub('_section', '')
      @value = value
      @charge_category_id = charge_category_id
    end

    def perform
      raise Quotations::TenderUpdater::UneditableFee unless fee_editable?

      ActiveRecord::Base.transaction do
        update_line_items
        update_charge
        update_parent(charge.parent)
        update_tender
      end
      @charge.charge_breakdown.shipment.update(updated_at: DateTime.now)
      tender
    end

    def charge
      @charge ||= charge_breakdown.charges.find_by(line_item_id: line_item.id)
    end

    private

    def fee_editable?
      return false if line_item.blank?
      return false if line_item.charge_category.code.match?(/\A(included|excluded|unknown)/)

      true
    end

    def update_line_items
      line_item.update!(amount: amount)
    end

    def update_tender
      new_amount = tender.line_items
                           .inject(Money.new(0, tender.amount.currency.iso_code)) { |total, item|
                             total + item.amount
                           }
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
      @charge_breakdown ||= Legacy::ChargeBreakdown.find_by(tender_id: tender.id)
    end

    def amount
      Money.new(value * 100, charge.price.currency)
    end
  end
end
