# frozen_string_literal: true

module TenderCalculator
  class TenderLineItems
    attr_reader :root

    def initialize(section_rates:, cargo:, margins: Rates::Margin.none, discounts: Rates::Discount.none)
      @section_rates = section_rates
      @cargo = cargo
      @margins = margins
      @discounts = discounts
      @root = TenderCalculator::ParentMap.new
      @line_items = []
      @margin_line_items = []
      @discount_line_items = []
    end

    def build
      @section_rates.each do |section_rate|
        cargo_rates = section_rate.cargos.sort_by(&:order).group_by(&:applicable_to)

        section_cargos_node = cargo_line_items(cargo_applicable_rates: cargo_rates['cargo'], rate: section_rate)
        section_node = percentage_line_items(cargo_rates['section'], section_cargos_node)

        # adding percentage margins with target = section_rate
        section_node = percentage_margins(target: section_rate, node: section_node)
        # adding flat margins with target = section_rate
        section_node = flat_margins(target: section_rate, node: section_node)

        section_node = construct_discounts(rate: section_rate, base_node: section_node)

        shipment_node = percentage_line_items(cargo_rates['shipment'], section_node)

        @root << shipment_node
      end

      # adding shipment margins with target = nil
      @root = percentage_margins(target: nil, node: @root)
      @root = flat_margins(target: nil, node: @root)

      # adding shipment discounts with target = nil
      @root = construct_discounts(rate: nil, base_node: @root)

      self
    end

    def cargo_line_items(cargo_applicable_rates:, rate:)
      all_cargo_node = TenderCalculator::ParentMap.new(rate: rate)

      cargo_applicable_rates.each do |cargo_rate|
        cargo_node = construct_buying_rates(rate: cargo_rate)
        cargo_node = construct_margins(rate: cargo_rate, base_node: cargo_node)
        cargo_node = construct_discounts(rate: cargo_rate.object, base_node: cargo_node)

        all_cargo_node << cargo_node
      end

      all_cargo_node
    end

    def construct_buying_rates(rate:)
      cargo_node = TenderCalculator::ParentMap.new(rate: rate)

      rate.targets.each do |cargo|
        cargo_rate_value = TenderCalculator::CargoRate.new(cargo_rate: rate, cargo: cargo).value
        fee_node = TenderCalculator::Value.new(value: cargo_rate_value)
        @line_items << fee_node
        cargo_node << fee_node
      end

      cargo_node
    end

    def construct_margins(rate:, base_node:)
      flat_margins = @margins.where(target: rate.object, operator: :addition)

      # adding percentage margins with target = cargo_rate
      percentage_margins_node = percentage_margins(target: rate.object, node: base_node)

      return percentage_margins_node if flat_margins.empty?

      flat_margins_node = TenderCalculator::ParentMap.new
      flat_margins_node << percentage_margins_node

      # adding flat margins with target = cargo_rate on cargos
      flat_margins.each do |margin|
        cargo_margin = TenderCalculator::Margin.new(margin: margin, cargo: @cargo)
        margin_node = TenderCalculator::Value.new(value: cargo_margin.amount, rate: margin)
        flat_margins_node << margin_node
        @margin_line_items << margin_node
      end

      flat_margins_node
    end

    def construct_discounts(rate:, base_node:)
      applicable_discounts = @discounts.where(target: rate).order(:order)
      branch = base_node

      applicable_discounts.each do |discount|
        klass = TenderCalculator::Discounts.const_get(discount.operator.camelize)
        branch = klass.apply(discount: discount, branch: branch, cargo: @cargo)
      end

      branch
    end

    def percentage_line_items(applicable_rates, node)
      branch = node

      applicable_rates.each do |cargo_rate|
        addition_node = TenderCalculator::Addition.new
        cargo_rate_value = TenderCalculator::CargoRate.new(cargo_rate: cargo_rate).value

        percentage_node = TenderCalculator::Multiplication.new(rate: cargo_rate)
        percentage_value_node = TenderCalculator::Value.new(value: cargo_rate_value)

        percentage_node << percentage_value_node
        percentage_node << branch
        addition_node << percentage_node
        addition_node << branch
        @line_items << percentage_node

        branch = addition_node
      end

      branch
    end

    def flat_margins(target:, node:)
      rate_flat_margins = @margins.where(target: target, operator: :addition)
      return node if rate_flat_margins.empty?

      with_margins_node = TenderCalculator::ParentMap.new(rate: target)
      with_margins_node << node

      rate_flat_margins.each do |margin|
        cargo_margin = TenderCalculator::Margin.new(margin: margin, cargo: @cargo)
        margin_node = TenderCalculator::Value.new(value: cargo_margin.amount, rate: margin)
        with_margins_node << margin_node
      end

      with_margins_node
    end

    def percentage_margins(target:, node:)
      rate_margins = @margins.where(target: target, operator: :multiplication).order(:order)
      return node if rate_margins.empty?

      branch = node

      rate_margins.each do |rate_margin|
        addition_node = TenderCalculator::Addition.new
        percentage_node = TenderCalculator::Multiplication.new(rate: rate_margin)
        value_node = TenderCalculator::Value.new(value: rate_margin.percentage)
        percentage_node << value_node
        percentage_node << branch
        addition_node << percentage_node
        addition_node << branch

        @margin_line_items << percentage_node
        branch = addition_node
      end

      branch
    end
  end
end
