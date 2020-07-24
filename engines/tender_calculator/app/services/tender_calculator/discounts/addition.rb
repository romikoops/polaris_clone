# frozen_string_literal: true

module TenderCalculator
  module Discounts
    class Addition
      def self.apply(discount:, branch:, cargo:)
        with_flat_discounts_node = TenderCalculator::AdditionMap.new
        cargo_discount = TenderCalculator::Discount.new(discount: discount, cargo: cargo)
        discount_node = TenderCalculator::Value.new(value: cargo_discount.amount, rate: discount)
        with_flat_discounts_node << discount_node
        with_flat_discounts_node << branch
        branch = with_flat_discounts_node

        branch
      end
    end
  end
end
