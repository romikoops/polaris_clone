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

    def prices
      result.map do |price_attributes|
        Price.new(price_attributes)
      end
    end

    private

    attr_reader :context, :rates

    def perform
      rates.map do |rate|
        reducer = Reducers.get(rate.fetch(:reducer, :first))
        calculated_price_value = reducer.apply(calculated_price_values(rate[:prices]))
        calculated_price_value = Reducers::Max.new.apply [calculated_price_value, BigDecimal(rate[:min_price])]

        {
          amount:      calculated_price_value,
          currency:    rate[:currency],
          category:    rate[:category],
          description: rate[:category]
        }
      end
    end

    def calculated_price_values(prices_data)
      filtered_prices_data(prices_data).map do |price_data|
        [
          context[price_data[:basis].to_sym],
          BigDecimal(price_data[:amount]),
          context.fetch(:quantity, 1)
        ].reduce(:*)
      end
    end

    def filtered_prices_data(prices_data)
      prices_data.select do |price_data|
        price_data[:rule].nil? ||
          RuleEngine.match(context: context.to_h, rule: price_data[:rule]).result
      end
    end
  end
end
