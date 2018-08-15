# frozen_string_literal: true

module ChargeCalculator
  class Price
    attr_reader :amount, :currency, :category, :children

    def initialize(amount: nil, currency: nil, category: nil, children: [])
      @amount   = amount
      @currency = currency
      @category = category
      @children = children
    end

    def to_h
      {
        amount:   amount,
        currency: currency,
        category: category
      }
    end

    def to_nested_hash
      return to_h if children.empty?

      to_h.merge(children: children.map(&:to_nested_hash))
    end
  end
end

