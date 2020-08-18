# frozen_string_literal: true

module ResultFormatter
  class FeeTableService
    SECTIONS = Quotations::LineItem.sections.keys

    def initialize(tender:, scope:, type: :table)
      @tender = tender
      @base_currency = tender.amount.currency
      @charge_breakdown = @tender.charge_breakdown
      @type = type
      @scope = scope
      @rows = [
        default_values.merge(
          value: value_with_currency(tender.amount),
          originalValue: value_with_currency(tender.original_amount),
          tenderId: tender.id,
          order: 0,
          level: 0
        )
      ]
    end

    def perform
      create_rows
      @rows
    end

    private

    attr_reader :tender, :rows, :scope, :charge_breakdown, :base_currency

    def create_rows
      sections_in_order.each do |section|
        items = tender.line_items.where(section: section)
        next if items.empty?

        charge_category = applicable_charge_category(section: section)
        section_row = default_values.merge(
          description: charge_category.name,
          value: value_with_currency(value(items: items)),
          originalValue: value_with_currency(original_value(items: items)),
          tenderId: tender.id,
          order: section_order(section: section),
          section: section,
          level: 1,
          chargeCategoryId: charge_category&.id
        )

        @rows << section_row
        if scope.dig(:quote_card, :sections, section.gsub("_section", ""))
          create_cargo_section_rows(row: section_row, items: items)
        end
      end
    end

    def create_cargo_section_rows(row:, items:)
      return create_cargo_currency_section_rows(row: row, items: items, cargo: nil, level: 3) if consolidated_cargo?

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
          chargeCategoryId: applicable_charge_category(cargo: cargo)&.id
        )
        @rows << cargo_row
        create_cargo_currency_section_rows(row: cargo_row, items: items_by_cargo, cargo: cargo, level: 3)
      end
    end

    def create_cargo_currency_section_rows(row:, items:, cargo:, level:)
      sorted_currency_items = sorted_items_for_currency_sections(items: items)
      if sorted_currency_items.keys.length == 1 && sorted_currency_items.first.first == base_currency.iso_code
        return create_fee_rows(row: row, items: items, level: level)
      end

      sorted_currency_items.each do |currency, items_by_currency|
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
          level: level
        )
        @rows << currency_row
        create_fee_rows(row: currency_row, items: items_by_currency, level: level + 1)
      end
    end

    def create_fee_rows(row:, items:, level:)
      sorted_items_for_section(items: items).each do |item|
        decorated_line_item = ::ResultFormatter::LineItemDecorator.new(item, context: {scope: scope})
        @rows << default_values.merge(
          editId: item.id,
          description: decorated_line_item.description,
          originalValue: value_with_currency(decorated_line_item.original_total),
          value: decorated_line_item.fee_context.merge(value_with_currency(item.amount)),
          order: 0,
          parentId: row[:id],
          lineItemId: item.id,
          tenderId: tender.id,
          section: item.section,
          level: level,
          code: item.code,
          chargeCategoryId: applicable_charge_category(item: item)&.id
        )
      end
    end

    def applicable_charge_category(item: nil, cargo: nil, section: nil)
      if item
        item.charge_category
      elsif item.nil? && section.present?
        section_code = section.sub("_section", "")
        org_charge_categories.find_by(code: section_code)
      else
        org_charge_categories.find_by(
          cargo_unit_id: cargo&.id,
          code: shipment_or_cargo_unit_code(cargo: cargo)
        )
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

    def sections_in_order
      SECTIONS.sort_by { |section| section_order(section: section) }
    end

    def section_order(section:)
      scope.dig(:quote_card, :order)&.index(section.gsub("_section", "")) ||
        SECTIONS.zip([1, 2, 3, 4, 5, 6, 7, 8]).to_h.fetch(section)
    end

    def value(items:, currency: base_currency)
      items.inject(Money.new(0, currency)) { |sum, item| sum + item.amount }
    end

    def original_value(items:, currency: base_currency)
      items.inject(Money.new(0, currency)) { |sum, item| sum + item.original_amount }
    end

    def value_with_currency(value)
      return nil if value.nil?

      {
        amount: @type == :table ? value.amount : value.format(symbol: false, rounded_infinite_precision: true),
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

    def consolidated_cargo?
      tender.load_type == "cargo_item" && scope.dig(:consolidation, :cargo, :backend)
    end

    def org_charge_categories
      Legacy::ChargeCategory.where(organization: organization)
    end

    def organization
      @organization ||= tender.quotation.organization
    end
  end
end
