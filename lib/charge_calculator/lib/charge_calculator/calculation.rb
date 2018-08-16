# frozen_string_literal: true

require "rule_engine"
require "bigdecimal"
require "pry"

module ChargeCalculator
  class Calculation
    def initialize(rates:, context:)
      @rates   = rates
      @context = context
    end

    def result
      @result ||= perform
    end

    private

    attr_reader :context, :rates

    def perform
      rates.map do |rate|
        reducer = Reducers.get(rate.fetch(:reducer, :first))
        calculated_price = reducer.apply(calculated_prices(rate[:prices]))
        calculated_price = Reducers::Max.new.apply [calculated_price, BigDecimal(rate[:min_price])]

        {
          amount:      calculated_price,
          currency:    rate[:currency],
          category:    rate[:category],
          description: rate[:category]
        }
      end
    end

    def calculated_prices(prices)
      filtered_prices(prices).map do |price|
        BigDecimal(context[price[:basis].to_sym]) * BigDecimal(price[:amount]) * BigDecimal(context.fetch(:quantity, 1))
      end
    end

    def filtered_prices(prices)
      prices.select do |price|
        price[:rule].nil? || RuleEngine.match(context: context.to_h, rule: price[:rule]).result
      end
    end
  end
end
