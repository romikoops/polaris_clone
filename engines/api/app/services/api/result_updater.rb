# frozen_string_literal: true

module Api
  class ResultUpdater
    UneditableFee = Class.new(StandardError)

    attr_reader :result, :line_item, :value

    def initialize(result:, line_item_id:, value:)
      @result = result
      @line_item = Journey::LineItem.find(line_item_id)
      @value = value
    end

    def perform
      raise Api::ResultUpdater::UneditableFee unless fee_editable?

      ActiveRecord::Base.transaction do
        update_line_item
        duplicate_other_line_items
      end
      result
    end

    private

    def fee_editable?
      return false if line_item.blank?
      return false if line_item.included || line_item.optional

      true
    end

    def update_line_item
      line_item.dup.update(
        total: amount,
        line_item_set: new_line_item_set,
        unit_price: amount / line_item.units
      )
    end

    def duplicate_other_line_items
      current_line_item_set.line_items.where.not(id: line_item.id).each do |current_line_item|
        current_line_item.dup.update(line_item_set: new_line_item_set)
      end
    end

    def amount
      Money.new(value.to_d * 100, line_item.total_currency)
    end

    def new_line_item_set
      @new_line_item_set ||= Journey::LineItemSet.new(result: result)
    end

    def current_line_item_set
      line_item.line_item_set
    end
  end
end
