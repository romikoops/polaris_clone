# frozen_string_literal: true

module ResultFormatter
  class FeeTableService
    SECTIONS = Quotations::LineItem.sections.keys

    def initialize(result:, scope:, type: :table)
      @result = result
      @type = type
      @scope = scope
      @rows = [
        default_values.merge(
          value: value_with_currency(value(items: current_line_item_set.line_items)),
          originalValue: value_with_currency(value(items: original_line_item_set.line_items)),
          tenderId: result.id,
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

    attr_reader :result, :rows, :scope, :charge_breakdown

    delegate :main_freight_section, to: :result

    def create_rows
      sections_in_order.each do |route_section|
        current_items = current_line_item_set.line_items.where(route_section: route_section)
        next if current_items.empty?

        charge_category = applicable_charge_category(route_section: route_section)
        section_row = default_values.merge(
          description: charge_category.name,
          value: value_with_currency(value(items: current_items)),
          originalValue: value_with_currency(original_value(items: current_items)),
          tenderId: result.id,
          order: route_section.order,
          section: charge_category.code,
          level: 1,
          chargeCategoryId: charge_category.id
        )
        @rows << section_row
        create_cargo_section_rows(row: section_row, items: current_items) if scope.dig(:quote_card, :sections, charge_category.code)
      end
    end

    def create_cargo_section_rows(row:, items:)
      return create_cargo_currency_section_rows(row: row, items: items, level: 3) if consolidated_cargo?

      items.group_by { |item| item.cargo_units.ids }.each do |cargo_unit_ids, items_by_cargo|
        fee_value = value(items: items_by_cargo)
        original_fee_value = original_value(items: items_by_cargo)
        cargo_row = default_values.merge(
          editId: cargo_unit_ids.join,
          description: cargo_description(cargo_units: items_by_cargo.first.cargo_units),
          value: value_with_currency(fee_value),
          originalValue: value_with_currency(original_fee_value),
          order: 0,
          parentId: row[:id],
          tenderId: result.id,
          section: section_code(route_section: items_by_cargo.first.route_section),
          level: 2,
          chargeCategoryId: ""
        )

        @rows << cargo_row
        create_cargo_currency_section_rows(row: cargo_row, items: items_by_cargo, level: 3)
      end
    end

    def create_cargo_currency_section_rows(row:, items:, level:)
      sorted_currency_items = sorted_items_for_currency_sections(items: items)
      return create_fee_rows(row: row, items: items, level: level) if sorted_currency_items.keys.length == 1 && sorted_currency_items.first.first == base_currency

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
          tenderId: result.id,
          section: section_code(route_section: items_by_currency.first.route_section),
          level: level
        )
        @rows << currency_row
        create_fee_rows(row: currency_row, items: items_by_currency, level: level + 1)
      end
    end

    def create_fee_rows(row:, items:, level:)
      fee_section_code = section_code(route_section: items.first.route_section)
      sorted_items_for_section(items: items).each do |item|
        decorated_line_item = ::ResultFormatter::LineItemDecorator.new(
          item,
          context: { scope: scope, mode_of_transport: main_freight_section.mode_of_transport }
        )
        @rows << default_values.merge(
          editId: item.id,
          description: decorated_line_item.description,
          originalValue: decorated_line_item.fee_context.merge(value_with_currency(original_fee_value(line_item: item))),
          value: decorated_line_item.fee_context.merge(value_with_currency(item.total)),
          order: 0,
          parentId: row[:id],
          lineItemId: item.id,
          tenderId: result.id,
          section: fee_section_code,
          level: level,
          code: item.fee_code,
          chargeCategoryId: applicable_charge_category(item: item)&.id
        )
      end
    end

    def applicable_charge_category(item: nil, route_section: nil)
      org_charge_categories.find_by(code: item&.fee_code || section_code(route_section: route_section))
    end

    def section_code(route_section:)
      if route_section.mode_of_transport == "carriage"
        code_from_carriage_section(route_section: route_section)
      else
        handle_non_carriage_section_code(route_section: route_section)
      end
    end

    def code_from_carriage_section(route_section:)
      route_section.order.zero? ? "trucking_pre" : "trucking_on"
    end

    def handle_non_carriage_section_code(route_section:)
      return "cargo" if route_section.from.geo_id != route_section.to.geo_id

      if route_section.order < main_freight_section.order
        "export"
      else
        "import"
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

    def cargo_description(cargo_units:)
      return "Shipment" if cargo_units.empty?

      return "Consolidated Cargo" if cargo_units.map(&:cargo_class).include?("aggregated_lcl") || cargo_units.length > 1

      cargo = cargo_units.first
      description = (cargo.cargo_class == "lcl" ? cargo.colli_type.to_s : cargo.cargo_class).humanize
      "#{cargo.quantity} x #{description}"
    end

    def sections_in_order
      scope.dig(:quote_card, :order).map do |key|
        {
          "trucking_pre" => result.pre_carriage_section,
          "export" => result.origin_transfer_section,
          "cargo" => result.main_freight_section,
          "import" => result.destination_transfer_section,
          "trucking_on" => result.on_carriage_section
        }[key]
      end.compact
    end

    def section_order(section:)
      scope.dig(:quote_card, :order)&.index(section.gsub("_section", "")) ||
        SECTIONS.zip([1, 2, 3, 4, 5, 6, 7, 8]).to_h.fetch(section)
    end

    def value(items:, currency: base_currency)
      items.inject(Money.new(0, currency)) do |sum, item|
        cents = item.total_currency == currency ? item.total_cents : item.total_cents * item.exchange_rate
        sum + Money.new(cents, currency)
      end
    end

    def original_value(items:, currency: base_currency)
      value(items: original_items(items: items), currency: currency)
    end

    def original_items(items:)
      original_line_item_set.line_items.select do |line_item|
        items.find { |item| item.fee_code == line_item.fee_code && item.route_section_id == line_item.route_section_id }
      end
    end

    def value_with_currency(value)
      return nil if value.nil?

      {
        amount: @type == :table ? value.amount : value.format(symbol: false, rounded_infinite_precision: true),
        currency: value.currency.iso_code
      }
    end

    def sorted_items_for_section(items:)
      return items if primary_code.blank? || items.first.route_section != main_freight_section

      primary_item = primary_item(items: items)
      items.reject { |item| item == primary_item }.sort_by { |item| -item.total }.unshift(primary_item).compact
    end

    def sorted_items_for_currency_sections(items:)
      return group_by_item_currency(items: items) if primary_code.blank? || items.first.route_section != main_freight_section

      primary_item = primary_item(items: items)
      return group_by_item_currency(items: items) if primary_item.nil?

      primary_currency = primary_item.total.currency.iso_code
      primary_currency_items = items.select { |item| item.total.currency.iso_code == primary_currency }
      {
        primary_currency => primary_currency_items
      }.merge(
        group_by_item_currency(items: items.reject { |item| primary_currency_items.include?(item) })
      )
    end

    def group_by_item_currency(items:)
      items.group_by { |line_item| line_item.total.currency.iso_code }
    end

    def primary_item(items:)
      items.find { |item| item.fee_code == primary_code.downcase }
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
        tenderId: result.id,
        code: nil,
        chargeCategoryId: nil,
        description: nil,
        section: nil
      }
    end

    def consolidated_cargo?
      cargo_units.exists?(cargo_class: %w[lcl aggregated_lcl]) && scope.dig(:consolidation, :cargo, :backend)
    end

    def org_charge_categories
      Legacy::ChargeCategory.where(organization: organization)
    end

    def query
      @query ||= result.result_set.query
    end

    delegate :organization, :client, :cargo_units, to: :query

    def base_currency
      @base_currency ||= result.result_set.currency
    end

    def current_line_item_set
      @current_line_item_set ||= result_line_item_sets.first
    end

    def original_line_item_set
      @original_line_item_set ||= result_line_item_sets.last
    end

    def result_line_item_sets
      @result_line_item_sets ||= Journey::LineItemSet.where(result: result).order(created_at: :desc)
    end

    def original_fee_value(line_item:)
      original_line_item_set.line_items.find_by(
        fee_code: line_item.fee_code, route_section: line_item.route_section
      ).total
    end
  end
end
