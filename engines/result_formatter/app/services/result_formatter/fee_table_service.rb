# frozen_string_literal: true

module ResultFormatter
  class FeeTableService
    SECTIONS = Quotations::LineItem.sections.keys

    def initialize(result:, scope:, type: :table)
      @result = result
      @type = type
      @scope = scope
    end

    def perform
      sections_in_order.inject(initial_rows) do |result_rows, (section, route_section)|
        result_rows | RouteSectionRows.new(section: section, route_section: route_section, scope: scope, type: type).rows
      end
    end

    private

    attr_reader :result, :scope, :type

    delegate :main_freight_section, to: :result

    def initial_rows
      @initial_rows ||= [
        Row.new(data: {
          value: MoneyFormatter.new(value:
            LineItemsTotal.new(line_items: current_line_item_set.line_items).value,
                                    type: type).format,
          originalValue: MoneyFormatter.new(value:
            LineItemsTotal.new(line_items: original_line_item_set.line_items).value,
                                            type: type).format,
          tenderId: result.id,
          order: 0,
          level: 0
        }).row
      ]
    end

    def sections_in_order
      scope.dig(:quote_card, :order)
        .map { |key| [key, route_section_lookup[key]] if route_section_lookup[key] }
        .compact
    end

    def route_section_lookup
      {
        "trucking_pre" => result.pre_carriage_section,
        "export" => result.origin_transfer_section,
        "cargo" => result.main_freight_section,
        "import" => result.destination_transfer_section,
        "trucking_on" => result.on_carriage_section
      }
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

    class RouteSectionRows
      def initialize(section:, route_section:, scope:, type:)
        @section = section
        @route_section = route_section
        @scope = scope
        @type = type
      end

      def rows
        [row] + child_rows.flatten
      end

      attr_reader :route_section, :section, :type, :scope

      private

      def row
        @row ||= Row.new(data: {
          description: charge_category.name,
          value: MoneyFormatter.new(value: fee_value, type: type).format,
          originalValue: MoneyFormatter.new(value: original_fee_value, type: type).format,
          tenderId: route_section.result_id,
          order: route_section.order,
          section: charge_category.code,
          level: 1,
          chargeCategoryId: charge_category.id
        }).row
      end

      def child_rows
        return [] unless scope.dig(:quote_card, :sections, section)
        return currency_children if consolidated_cargo?

        cargo_children
      end

      def currency_children
        RouteSectionCurrencySorter.new(parent: row, line_items: route_section.line_items, scope: scope, type: type).rows
      end

      def cargo_children
        grouped_line_items.map do |items|
          RouteSectionCargoRows.new(parent: row, line_items: items, scope: scope, type: type).rows
        end
      end

      def grouped_line_items
        route_section.line_items.where(line_item_set: current_line_item_set)
          .group_by { |line_item| line_item.cargo_units.ids }
          .sort_by { |cargo_unit_ids, _items_by_cargo| -cargo_unit_ids.length }
          .map(&:last)
      end

      def charge_category
        @charge_category ||= Legacy::ChargeCategory.find_by(code: section, organization_id: Organizations.current_id)
      end

      def current_line_item_set
        @current_line_item_set ||= Journey::LineItemSet.where(result: route_section.result_id).order(created_at: :desc).first
      end

      def fee_value
        LineItemsTotal.new(line_items: current_line_item_set.line_items, original: false).value
      end

      def original_fee_value
        LineItemsTotal.new(line_items: current_line_item_set.line_items, original: true).value
      end

      def consolidated_cargo?
        lcl_cargo_units? && scope.dig(:consolidation, :cargo, :backend)
      end

      def lcl_cargo_units?
        route_section.result.query.cargo_units.exists?(cargo_class: %w[lcl aggregated_lcl])
      end
    end

    class RouteSectionCargoRows
      def initialize(parent:, line_items:, scope:, type:)
        @parent = parent
        @line_items = line_items
        @scope = scope
        @type = type
      end

      def rows
        [row] + cargo_currency_rows
      end

      attr_reader :parent, :line_items, :type, :scope

      private

      def row
        @row ||= Row.new(data: {
          editId: cargo_units.pluck(:id).join,
          description: cargo_description,
          value: MoneyFormatter.new(value: fee_value, type: type).format,
          originalValue: MoneyFormatter.new(value: original_fee_value, type: type).format,
          order: 0,
          parentId: parent[:id],
          tenderId: parent[:tenderId],
          section: parent[:section],
          level: parent[:level] + 1,
          chargeCategoryId: ""
        }).row
      end

      def cargo_currency_rows
        RouteSectionCurrencySorter.new(parent: row, line_items: line_items, scope: scope, type: type).rows
      end

      def cargo_description
        return "Shipment" if cargo_units.empty?

        return "Consolidated Cargo" if cargo_units.map(&:cargo_class).include?("aggregated_lcl") || cargo_units.length > 1

        cargo = cargo_units.first
        is_lcl = cargo.cargo_class == "lcl"
        description = (is_lcl ? cargo.colli_type.to_s : cargo.cargo_class).humanize
        description.upcase! unless is_lcl
        "#{cargo.quantity} x #{description}"
      end

      def fee_value
        LineItemsTotal.new(line_items: line_items, original: false).value
      end

      def original_fee_value
        LineItemsTotal.new(line_items: line_items, original: true).value
      end

      def cargo_units
        @cargo_units ||= line_items.first.cargo_units
      end
    end

    class RouteSectionCurrencySorter
      def initialize(parent:, line_items:, scope:, type:)
        @parent = parent
        @line_items = line_items
        @scope = scope
        @type = type
      end

      def rows
        return line_item_rows if single_currency_quote?

        sorted_items_for_currency_sections.map do |currency, items|
          RouteSectionCurrencyRows.new(parent: parent, currency: currency, line_items: items, scope: scope, type: type).rows
        end
      end

      attr_reader :parent, :line_items, :type, :scope

      private

      def single_currency_quote?
        grouped_by_currency.keys.length == 1 && grouped_by_currency.first.first == currency
      end

      def sorted_items_for_currency_sections
        return grouped_by_currency if primary_code.blank? || aux_freight_section? || primary_item.blank?

        { primary_currency => sorted_line_items(items: grouped_by_currency.delete(primary_currency)) }
          .merge(grouped_by_currency)
      end

      def grouped_by_currency
        @grouped_by_currency ||= line_items.group_by(&:total_currency)
      end

      def primary_item
        @primary_item ||= line_items.find { |item| item.fee_code == primary_code.downcase }
      end

      def aux_freight_section?
        %w[relay carriage].include?(route_section.mode_of_transport)
      end

      def line_item_rows
        RouteSectionFeeRows.new(
          parent: parent,
          line_items: sorted_line_items(items: line_items),
          scope: scope,
          type: type
        ).rows
      end

      def sorted_line_items(items:)
        return items if primary_item.blank?

        items.delete(primary_item)
        items.unshift(primary_item)
      end

      def primary_currency
        @primary_currency ||= primary_item.total_currency
      end

      def primary_code
        @primary_code = scope.fetch(:primary_freight_code, nil)&.to_s
      end

      def currency
        @currency ||= route_section.result.query.currency
      end

      def route_section
        @route_section ||= line_items.first.route_section
      end
    end

    class RouteSectionCurrencyRows
      def initialize(parent:, currency:, line_items:, scope:, type:)
        @parent = parent
        @currency = currency
        @line_items = line_items
        @scope = scope
        @type = type
      end

      def rows
        [row] + line_item_rows
      end

      attr_reader :parent, :line_items, :currency, :type, :scope

      private

      def row
        @row ||= Row.new(data: {
          description: "Fees charged in #{currency}:",
          value: MoneyFormatter.new(value: fee_value, type: type).format,
          originalValue: MoneyFormatter.new(value: original_fee_value, type: type).format,
          order: 0,
          parentId: parent[:id],
          lineItemId: nil,
          tenderId: parent[:tenderId],
          section: parent[:section],
          level: parent[:level] + 1
        }).row
      end

      def fee_value
        LineItemsTotal.new(line_items: line_items, original: false, convert: false).value
      end

      def original_fee_value
        LineItemsTotal.new(line_items: line_items, original: true, convert: false).value
      end

      def line_item_rows
        RouteSectionFeeRows.new(parent: parent, line_items: line_items, scope: scope, type: type).rows
      end
    end

    class RouteSectionFeeRows
      def initialize(parent:, line_items:, scope:, type:)
        @parent = parent
        @line_items = line_items
        @scope = scope
        @type = type
      end

      def rows
        decorated_line_items.map do |item|
          RouteSectionFeeRow.new(parent: parent, line_item: item, type: type).row
        end
      end

      attr_reader :parent, :line_items, :scope, :type

      private

      def decorated_line_items
        @decorated_line_items ||= ::ResultFormatter::LineItemDecorator.decorate_collection(
          line_items,
          context: { scope: scope }
        )
      end
    end

    class RouteSectionFeeRow
      def initialize(parent:, line_item:, type:)
        @parent = parent
        @line_item = line_item
        @type = type
      end

      def row
        Row.new(data: {
          editId: line_item.id,
          description: line_item.description,
          originalValue: line_item.fee_context.merge(MoneyFormatter.new(value: original_fee_value, type: type).format),
          value: value,
          order: 0,
          parentId: parent[:id],
          lineItemId: line_item.id,
          tenderId: parent[:tenderId],
          section: parent[:section],
          level: parent[:level] + 1,
          code: line_item.fee_code,
          rateFactor: line_item.rate_factor,
          rate: line_item.rate
        }).row
      end

      attr_reader :parent, :line_item, :type

      private

      def value
        line_item.fee_context.merge(MoneyFormatter.new(value: line_item.total, type: type).format)
      end

      def original_fee_value
        LineItemsTotal.new(line_items: [line_item], original: true, convert: false).value
      end
    end

    class Row
      def initialize(data:)
        @data = data
      end

      attr_reader :data

      def row
        default_values.merge(data)
      end

      private

      def default_values
        {
          id: SecureRandom.uuid,
          editId: nil,
          order: 0,
          parentId: nil,
          lineItemId: nil,
          code: nil,
          chargeCategoryId: nil,
          description: nil,
          section: nil
        }
      end
    end

    class LineItemsTotal
      def initialize(line_items:, original: false, convert: true)
        @line_items = line_items
        @original = original
        @convert = convert
      end

      attr_reader :line_items, :original, :convert

      def value
        items.inject(Money.new(0, currency)) do |sum, item|
          cents = item.total_currency == currency ? item.total_cents : item.total_cents * item.exchange_rate
          sum + Money.new(cents, currency)
        end
      end

      private

      def items
        original ? original_line_items : line_items
      end

      def line_item_set
        @line_item_set ||= line_items.first.line_item_set
      end

      def original_line_item_set
        @original_line_item_set ||= line_item_set.result.line_item_sets.order(:created_at).first
      end

      def original_line_items
        # rubocop:disable Rails/PluckInWhere   not an ActiveRecord relation
        original_line_item_set.line_items.where(fee_code: line_items.pluck(:fee_code), route_section: route_section)
        # rubocop:enable Rails/PluckInWhere
      end

      def route_section
        @route_section ||= line_items.first.route_section
      end

      def currency
        @currency ||= convert ? route_section.result.query.currency : line_items.first.total_currency
      end
    end

    class MoneyFormatter
      def initialize(value:, type:)
        @value = value
        @type = type
      end

      attr_reader :value, :type

      def format
        return nil if value.nil?

        {
          amount: type == :table ? value.amount : value.format(symbol: false, rounded_infinite_precision: true),
          currency: value.currency.iso_code
        }
      end
    end
  end
end
