# frozen_string_literal: true

module TenderCalculator
  module Discounts
    class Multiplication
      attr_reader :values

      def self.apply(discount:, branch:, cargo: nil)
        addition_node = TenderCalculator::Addition.new
        percentage_node = TenderCalculator::Multiplication.new(rate: discount)
        decorated_discount = TenderCalculator::Discount.new(discount: discount)
        value_node = TenderCalculator::Value.new(value: decorated_discount.amount)
        percentage_node << value_node
        percentage_node << branch
        addition_node << percentage_node
        addition_node << branch
        addition_node
      end
    end
  end
end
