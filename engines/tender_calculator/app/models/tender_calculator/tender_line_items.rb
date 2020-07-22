# frozen_string_literal: true

module TenderCalculator
  class TenderLineItems
    attr_reader :root

    def initialize(section_rates:, cargo:, margins: Rates::Margin.none)
      @section_rates = section_rates
      @cargo = cargo
      @margins = margins
      @root = TenderCalculator::ParentMap.new
      @line_items = []
      @margin_line_items = []
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

        shipment_node = percentage_line_items(cargo_rates['shipment'], section_node)

        @root << shipment_node
      end

      # adding shipment margins with target = nil
      @root = percentage_margins(target: nil, node: @root)
      @root = flat_margins(target: nil, node: @root)

      self
    end

    def cargo_line_items(cargo_applicable_rates:, rate:)
      all_cargo_node = TenderCalculator::ParentMap.new(rate: rate)

      cargo_applicable_rates.each do |cargo_rate|
        targeted_margins = @margins.where(target: cargo_rate.object, operator: :addition)
        cargo_node = TenderCalculator::ParentMap.new(rate: cargo_rate)

        cargo_rate.targets.each do |cargo|
          cargo_rate_value = TenderCalculator::CargoRate.new(cargo_rate: cargo_rate, cargo: cargo).value
          fee_node = TenderCalculator::Value.new(value: cargo_rate_value)
          @line_items << fee_node
          cargo_node << fee_node
        end

        # adding percentage margins with target = cargo_rate
        cargo_node_with_margins = percentage_margins(target: cargo_rate.object, node: cargo_node)

        # adding flat margins with target = cargo_rate on cargos
        targeted_margins.each do |margin|
          cargo_margin = TenderCalculator::Margin.new(margin: margin, cargo: @cargo)
          margin_node = TenderCalculator::Value.new(value: cargo_margin.amount, rate: margin)
          cargo_node_with_margins << margin_node
          @margin_line_items << margin_node
        end

        all_cargo_node << cargo_node_with_margins
      end

      all_cargo_node
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
      rate_margins = @margins.where(target: target, operator: :percentage).order(:order)
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
