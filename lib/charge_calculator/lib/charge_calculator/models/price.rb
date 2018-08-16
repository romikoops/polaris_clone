# frozen_string_literal: true

module ChargeCalculator
  class Price
    attr_reader :amount, :currency, :category, :description, :children

    def initialize(amount: nil, currency: nil, category: nil, description: nil, children: [])
      @amount      = amount
      @currency    = currency
      @category    = category
      @description = description
      @children    = children
    end

    def to_h
      {
        amount:      amount,
        currency:    currency,
        category:    category,
        description: description
      }
    end

    def to_nested_hash
      to_h.merge(children: children.map(&:to_nested_hash))
    end
  end
end
