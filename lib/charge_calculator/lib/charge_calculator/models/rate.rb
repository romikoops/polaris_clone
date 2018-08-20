# frozen_string_literal: true

module Models
  class Rate
    attr_reader :kind, :min_price, :currency, :reducer, :prices_data

    def initialize(kind: nil, min_price: nil, currency: nil, reducer: nil, prices: [])
      @kind        = kind
      @min_price   = min_price
      @currency    = currency
      @reducer     = reducer
      @prices_data = prices
    end

    def price(context)
      reducer = Reducers.get(rate.fetch(:reducer, :first))
      calculated_price_value = reducer.apply(calculated_price_values(context))
      calculated_price_value = Reducers::Max.new.apply [calculated_price_value, BigDecimal(rate[:min_price])]

      Models::Price.new(
        amount:      calculated_price_value,
        currency:    rate[:currency],
        category:    rate[:category],
        description: rate[:category]
      )
    end

    private

    def calculated_price_values(context)
      filtered_prices_data(prices_data).map do |price_data|
        calculator = Calculators.get(price_data[:basis].to_sym)

        calculator.result(price_data: price_data, context: context)
      end
    end

    def filtered_prices_data(context)
      prices_data.select do |price_data|
        price_data[:rule].nil? ||
          RuleEngine.match(context: context.to_h, rule: price_data[:rule]).result
      end
    end
  end
end
