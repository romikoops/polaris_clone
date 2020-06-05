# frozen_string_literal: true

module ResultFormatter
  class FeeTableService
    SECTIONS = %w[cargo_section
      trucking_pre_section
      trucking_on_section
      export_section
      import_section].freeze

    def initialize(tender:, scope:)
      @tender = tender
      @base_currency = tender.amount.currency
      @charge_breakdown = @tender.charge_breakdown
      @rows = [
        default_values.merge(
          value: value_with_currency(tender.amount),
          originalValue: value_with_currency(tender.original_amount),
          tenderId: tender.id,
          order: 0,
          level: 0
        )
      ]
      @scope = scope
    end

    def perform
      create_rows
      @rows
    end

    private

    attr_reader :tender, :rows, :scope, :charge_breakdown, :base_currency

    def create_rows
      tender.line_items.group_by(&:section).each do |section, items|
        charge_category_id = applicable_charge_category_id(section: section)
        section_row = default_values.merge(
          description: section_description(section: section),
          value: value_with_currency(value(items: items)),
          originalValue: value_with_currency(original_value(items: items)),
          tenderId: tender.id,
          order: section_order(section: section),
          section: section,
          level: 1,
          chargeCategoryId: charge_category_id
        )
        @rows << section_row
        create_cargo_section_rows(row: section_row, items: items)
      end
    end

    def create_cargo_section_rows(row:, items:)
      items.group_by(&:cargo).each do |cargo, items_by_cargo|
        fee_value = value(items: items_by_cargo)
        original_fee_value = original_value(items: items_by_cargo)
        cargo_row = default_values.merge(
          editId: cargo&.id,
          description: cargo_description(cargo: cargo),
          value: value_with_currency(fee_value),
          originalValue: value_with_currency(original_fee_value),
          order: 0,
          parentId: row[:id],
          tenderId: tender.id,
          section: items_by_cargo.first.section,
          level: 2,
          chargeCategoryId: applicable_charge_category_id(cargo: cargo)
        )
        @rows << cargo_row
        create_cargo_currency_section_rows(row: cargo_row, items: items_by_cargo, cargo: cargo)
      end
    end

    def create_cargo_currency_section_rows(row:, items:, cargo:)
      sorted_items_for_currency_sections(items: items)
        .each do |currency, items_by_currency|
        fee_value = value(items: items_by_currency, currency: currency)
        original_fee_value = original_value(items: items_by_currency, currency: currency)
        currency_row = default_values.merge(
          description: currency_description(currency: currency),
          value: value_with_currency(fee_value),
          originalValue: value_with_currency(original_fee_value),
          order: 0,
          parentId: row[:id],
          lineItemId: nil,
          tenderId: tender.id,
          section: items_by_currency.first.section,
          level: 3
        )
        @rows << currency_row
        create_fee_rows(row: currency_row, items: items_by_currency)
      end
    end

    def create_fee_rows(row:, items:)
      sorted_items_for_section(items: items).each do |item|
        decorated_line_item = ::ResultFormatter::LineItemDecorator.new(item, context: {scope: scope})
        @rows << default_values.merge(
          editId: item.id,
          description: decorated_line_item.description,
          originalValue: value_with_currency(decorated_line_item.original_total),
          value: decorated_line_item.total_and_currency,
          order: 0,
          parentId: row[:id],
          lineItemId: item.id,
          tenderId: tender.id,
          section: item.section,
          level: 4,
          code: item.code,
          chargeCategoryId: applicable_charge_category_id(item: item)
        )
      end
    end

    def applicable_charge_category_id(item: nil, cargo: nil, section: nil)
      if item
        item.charge_category_id
      elsif item.nil? && section.present?
        section_code = section.sub("_section", "")
        charge_breakdown.charge_categories.find_by(code: section_code)&.id
      else
        charge_breakdown.charge_categories.find_by(
          cargo_unit_id: cargo&.id,
          code: shipment_or_cargo_unit_code(cargo: cargo)
        )&.id
      end
    end

    def shipment_or_cargo_unit_code(cargo:)
      if cargo.present?
        cargo.is_a?(Legacy::Container) ? "container" : "cargo_item"
      else
        "shipment"
      end
    end

    def currency_description(currency:)
      "Fees charged in #{currency}:"
    end

    def cargo_description(cargo:)
      return "Shipment" if cargo.blank?

      return "Consolidated Cargo" if cargo.is_a?(Legacy::AggregatedCargo)

      "#{cargo.quantity} x #{cargo_class_string(cargo: cargo)}"
    end

    def cargo_class_string(cargo:)
      if cargo.is_a?(Legacy::Container)
        cargo.cargo_class.humanize
      else
        cargo.cargo_item_type.description
      end
    end

    def section_description(section:)
      SECTIONS.zip(["Freight Charges",
        "Pre-Carriage",
        "On-Carriage",
        "Export Local Charges",
        "Import Local Charges"]).to_h.fetch(section)
    end

    def section_order(section:)
      SECTIONS.zip([3, 1, 5, 2, 4]).to_h.fetch(section)
    end

    def value(items:, currency: base_currency)
      items.sum(Money.new(0, currency), &:amount)
    end

    def original_value(items:, currency: base_currency)
      items.sum(Money.new(0, currency), &:original_amount)
    end

    def value_with_currency(value)
      return nil if value.nil?

      {
        amount: value.amount,
        currency: value.currency.iso_code
      }
    end

    def sorted_items_for_section(items:)
      return items if primary_code.blank? || items.first.section != "cargo_section"

      primary_item = primary_item(items: items)
      items.reject { |item| item == primary_item }.sort_by { |item| -item.amount }.unshift(primary_item).compact
    end

    def sorted_items_for_currency_sections(items:)
      if primary_code.blank? || items.first.section != "cargo_section"
        return group_by_item_currency(items: items)
      end

      primary_item = primary_item(items: items)
      return group_by_item_currency(items: items) if primary_item.nil?

      primary_currency = primary_item.amount.currency.iso_code
      primary_currency_items = items.select { |item| item.amount.currency.iso_code == primary_currency }
      {
        primary_currency => primary_currency_items
      }.merge(
        group_by_item_currency(items: items.reject { |item| primary_currency_items.include?(item) })
      )
    end

    def group_by_item_currency(items:)
      items.group_by { |line_item| line_item.amount.currency.iso_code }
    end

    def primary_item(items:)
      items.find { |item| item.code == primary_code.downcase }
    end

    def primary_code
      @primary_code = scope.fetch(:primary_freight_code, nil)&.to_s
    end

    def default_values
      {
        id: SecureRandom.uuid,
        editId: nil,
        order: 0,
        parentId: nil,
        lineItemId: nil,
        tenderId: tender.id,
        code: nil,
        chargeCategoryId: nil,
        description: nil,
        section: nil
      }
    end
  end
end
