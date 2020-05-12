# frozen_string_literal: true

module TenderCalculator
  class TenderLineItems
    attr_reader :root

    def initialize(section_rates:)
      @section_rates = section_rates
      @root = TenderCalculator::ParentMap.new
      @line_items = []
    end

    def build
      @section_rates.each do |section_rate|
        cargo_rates = section_rate.cargos.sort_by(&:order).group_by(&:applicable_to)

        section_cargos_node = cargo_line_items(cargo_rates['cargo'])
        section_node = percentage_line_items(cargo_rates['section'], section_cargos_node)
        shipment_node = percentage_line_items(cargo_rates['shipment'], section_node)

        @root << shipment_node
      end

      self
    end

    def cargo_line_items(cargo_applicable_rates)
      all_cargo_node = TenderCalculator::ParentMap.new

      cargo_applicable_rates.each do |cargo_rate|
        cargo_node = TenderCalculator::ParentMap.new
        all_cargo_node << cargo_node

        cargo_rate.targets.each do |cargo|
          cargo_rate_value = TenderCalculator::CargoRate.new(cargo_rate: cargo_rate, cargo: cargo).value
          value_node = TenderCalculator::Value.new(value: cargo_rate_value)
          @line_items << value_node
          cargo_node << value_node
        end
      end

      all_cargo_node
    end

    def percentage_line_items(applicable_rates, node)
      branch = node

      applicable_rates.each do |cargo_rate|
        percentage_node = TenderCalculator::Multiplication.new
        cargo_rate_value = TenderCalculator::CargoRate.new(cargo_rate: cargo_rate).value
        value_node = TenderCalculator::Value.new(value: cargo_rate_value)
        percentage_node << value_node
        percentage_node << branch
        @line_items << percentage_node
        branch = percentage_node
      end

      branch
    end
  end
end
