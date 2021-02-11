# frozen_string_literal: true

module Api
  class LegacyQuote
    def self.quote(result:, scope:, admin: false)
      new(
        result: result,
        scope: scope,
        admin: admin
      ).perform
    end

    def initialize(result:, scope:, admin: false)
      @result = result
      @scope = scope
      @admin = admin
    end

    def perform
      route_sections.each_with_object(initial_state) do |route_section, memo|
        memo.merge!(legacy_section_format(route_section: route_section))
      end
    end

    private

    attr_reader :result
    delegate :client, :creator, :organization, to: :query

    def admin?
      @admin
    end

    def initial_state
      {
        total: grand_total,
        edited_total: edited_grand_total,
        name: "Grand Total"
      }
    end

    def grand_total
      return if should_hide_grand_total?

      money_attributes(money: line_items_total(items: line_items))
    end

    def edited_grand_total
      return if should_hide_grand_total? || !edited?

      money_attributes(money: line_items_total(items: original_line_item_set.line_items))
    end

    def scope
      @scope ||= OrganizationManager::ScopeService.new(target: client, organization: organization).fetch
    end

    def currency
      @currency ||= Users::Settings.find_by(user: client)&.currency || scope.dig(:default_currency)
    end

    def legacy_section_format(route_section:)
      {
        legacy_section_key(route_section: route_section) => legacy_cargo_sections(route_section: route_section)
      }
    end

    def legacy_cargo_sections(route_section:)
      legacy_item_grouping(items: line_items.where(route_section: route_section))
        .each_with_object(route_section_initial_state(route_section: route_section)) do |(group_key, items), memo|
        memo[group_key] = grouped_line_item_hash(items: items)
        memo
      end
    end

    def grouped_line_item_hash(items:)
      item_grouping = Hash.new { |h, k| h[k] = {} }.merge(
        "total" => sub_total(items: items),
        "name" => ""
      )
      items.each_with_object(item_grouping) do |item, memo|
        memo.merge!(line_item_hash(line_item: item))
      end
    end

    def route_section_initial_state(route_section:)
      Hash.new { |h, k| h[k] = {} }.merge(
        "total" => sub_total(items: line_items.where(route_section: route_section)),
        "edited_total" => edited_sub_total(
          items: original_line_item_set.line_items.where(route_section: route_section)
        ),
        "name" => legacy_charge_category_name(route_section: route_section)
      )
    end

    def sub_total(items:)
      return if should_hide_sub_totals?

      money_attributes(
        money: line_items_total(
          items: items
        )
      )
    end

    def edited_sub_total(items:)
      return if should_hide_sub_totals? || !edited?

      money_attributes(
        money: line_items_total(
          items: items
        )
      )
    end

    def line_item_hash(line_item:)
      {
        line_item.fee_code.downcase => money_attributes(money: line_item.total).merge(name: line_item.description)
      }
    end

    def unit_key(line_item:)
      return load_type if scope.dig(:consolidation, :backend, :cargo).present?

      cargo_unit = line_item.cargo_units.first
      return "shipment" if cargo_unit.blank?

      cargo_unit.id
    end

    def legacy_item_grouping(items:)
      items.group_by { |item| unit_key(line_item: item) }
    end

    def legacy_section_key(route_section:)
      if route_section.mode_of_transport == "carriage"
        legacy_carriage_key(route_section: route_section)
      elsif route_section.from == route_section.to
        legacy_transfer_key(route_section: route_section)
      else
        "cargo"
      end
    end

    def legacy_charge_category_name(route_section:)
      Legacy::ChargeCategory.find_by(
        organization: organization,
        code: legacy_section_key(route_section: route_section)
      ).name
    end

    def legacy_carriage_key(route_section:)
      "trucking_#{route_section.order == 0 ? "pre" : "on"}"
    end

    def legacy_transfer_key(route_section:)
      if route_sections.first.mode_of_transport == "carriage" && route_section.order >= 3 ||
          route_sections.first.mode_of_transport == "ocean"
        "import"
      else
        "export"
      end
    end

    def route_sections
      @route_sections ||= Journey::RouteSection.where(id: line_items.select(:route_section_id)).order(order: :asc)
    end

    def line_items
      @line_items ||= Journey::LineItem.where(line_item_set: current_line_item_set)
    end

    def current_line_item_set
      @current_line_item_set ||= Journey::LineItemSet.where(result: result).order(created_at: :desc).first
    end

    def load_type
      @load_type ||= cargo_units.exists?(cargo_class: "lcl") ? "cargo_item" : "container"
    end

    def cargo_units
      @cargo_units ||= query.cargo_units
    end

    def original_line_item_set
      @original_line_item_set ||= Journey::LineItemSet.where(result: result).order(created_at: :asc).first
    end

    def edited?
      current_line_item_set != original_line_item_set
    end

    def line_items_total(items:)
      items.inject(Money.new(0, currency)) { |sum, item|
        sum + item.total
      }
    end

    def should_hide_sub_totals?
      return false if admin?

      (guest? || hidden_sub_total)
    end

    def should_hide_grand_total?
      return false if admin?

      ((hidden_grand_total || guest?) ||
        (hide_converted_grand_total && currency_count > 1))
    end

    def hidden_grand_total
      scope.fetch(:hide_grand_total, false)
    end

    def hidden_sub_total
      scope.fetch(:hide_sub_totals, false)
    end

    def hide_converted_grand_total
      scope.fetch(:hide_converted_grand_total, false)
    end

    def guest?
      query.client_id.nil?
    end

    def query
      @query ||= result.result_set.query
    end

    def currency_count
      line_items.select(:total_currency).distinct.count
    end

    def money_attributes(money:)
      {
        value: money.amount,
        currency: money.currency.iso_code
      }
    end
  end
end
