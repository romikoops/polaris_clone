# frozen_string_literal: true

module Api
  class FeeTableService
    SECTIONS = %w[cargo_section
                  trucking_pre_section
                  trucking_on_section
                  export_section
                  import_section].freeze

    def initialize(tender:, scope:)
      @tender = tender
      @charge_breakdown = @tender.charge_breakdown
      @rows = []
      @scope = scope
    end

    def perform
      create_rows
      @rows
    end

    def create_rows
      tender.line_items.group_by(&:section).each do |section, items|
        charge_category_id = applicable_charge_category_id(section: section)
        section_row = {
          id: SecureRandom.uuid,
          description: section_description(section: section),
          value: value_with_currency(value(items: items, charge_category_id: charge_category_id)),
          lineItemId: nil,
          tenderId: tender.id,
          order: section_order(section: section),
          section: section,
          level: 0,
          chargeCategoryId: charge_category_id
        }
        @rows << section_row
        create_cargo_section_rows(row: section_row, items: items)
      end
    end

    def create_cargo_section_rows(row:, items:)
      items.group_by(&:cargo).each do |cargo, items_by_cargo|
        charge_category_id = applicable_charge_category_id(cargo: cargo)
        fee_value = value(items: items_by_cargo, charge_category_id: charge_category_id)
        cargo_row = {
          id: SecureRandom.uuid,
          editId: cargo&.id,
          description: cargo_description(cargo: cargo),
          value: value_with_currency(fee_value),
          order: 0,
          parentId: row[:id],
          lineItemId: nil,
          tenderId: tender.id,
          section: items_by_cargo.first.section,
          level: 1,
          chargeCategoryId: applicable_charge_category_id(cargo: cargo)
        }
        @rows << cargo_row
        create_cargo_currency_section_rows(row: cargo_row, items: items_by_cargo, cargo: cargo)
      end
    end

    def create_cargo_currency_section_rows(row:, items:, cargo:)
      items.group_by { |line_item| line_item.amount.currency.iso_code }
           .each do |currency, items_by_currency|
        fee_value = value(items: items_by_currency, charge_category_id: nil)
        currency_row = {
          id: SecureRandom.uuid,
          description: currency_description(currency: currency),
          value: value_with_currency(fee_value),
          order: 0,
          parentId: row[:id],
          lineItemId: nil,
          tenderId: tender.id,
          section: items_by_currency.first.section,
          level: 2,
          chargeCategoryId: nil
        }
        @rows << currency_row
        create_fee_rows(row: currency_row, items: items_by_currency)
      end
    end

    def create_fee_rows(row:, items:)
      items.each do |item|
        decorated_line_item = Api::V1::LineItemDecorator.new(item, context: { scope: scope })
        @rows << {
          id: SecureRandom.uuid,
          editId: item.id,
          description: decorated_line_item.description,
          value: value_with_currency(decorated_line_item.total),
          order: 0,
          parentId: row[:id],
          lineItemId: item.id,
          tenderId: tender.id,
          section: item.section,
          level: 3,
          chargeCategoryId: applicable_charge_category_id(item: item)
        }
      end
    end

    def applicable_charge_category_id(item: nil, cargo: nil, section: nil)
      if item
        item.charge_category_id
      elsif item.nil? && section.present?
        section_code = section.sub('_section', '')
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
        cargo.is_a?(Legacy::Container) ? 'container' : 'cargo_item'
      else
        'shipment'
      end
    end

    def currency_description(currency:)
      "Fees charged in #{currency}:"
    end

    def cargo_description(cargo:)
      return 'Shipment' if cargo.blank?

      return 'Consolidated Cargo' if cargo.is_a?(Legacy::AggregatedCargo)

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
      SECTIONS.zip(['Freight Charges',
                    'Pre-Carriage',
                    'On-Carriage',
                    'Export Local Charges',
                    'Import Local Charges']).to_h.fetch(section)
    end

    def section_order(section:)
      SECTIONS.zip([3, 1, 5, 2, 4]).to_h.fetch(section)
    end

    def value(items:, charge_category_id:)
      edited_price = charge_breakdown.charges.find_by(children_charge_category_id: charge_category_id)&.edited_price

      (edited_price&.money || items.sum(&:amount))
    end

    def value_with_currency(value)
      return nil unless value

      {
        amount: value.amount,
        currency: value.currency.iso_code
      }
    end

    attr_reader :tender, :rows, :scope, :charge_breakdown
  end
end
