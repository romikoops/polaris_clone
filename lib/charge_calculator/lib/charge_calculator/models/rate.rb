# frozen_string_literal: true

module ChargeCalculator
  module Models
    class Rate
      attr_reader :kind, :category, :min_price, :currency, :reducer

      def initialize(kind: nil, category:, min_price: nil, currency:, reducer: nil, prices: [])
        @kind        = kind
        @category    = category
        @min_price   = BigDecimal(min_price)
        @currency    = currency
        @reducer     = Reducers.get(reducer&.to_sym || :first)
        @prices_data = prices
      end

      def price(context:)
        calculated_price_value = reducer.apply(calculated_price_values(context: context)) || 0

        calculated_price_value = Reducers::Max.new.apply([calculated_price_value, min_price])

        Models::Price.new(
          amount: calculated_price_value,
          currency: currency,
          category: category,
          description: category
        )
      end

      def kind?(kind)
        self.kind == kind
      end

      private

      attr_reader :prices_data

      def calculated_price_values(context:)
        filtered_prices_data(context: context).map do |price_data|
          calculator = Calculators.get(price_data[:basis].to_sym)

          calculator.result(amount: BigDecimal(price_data[:amount]), context: context)
        end
      end

      def filtered_prices_data(context:)
        prices_data.select do |price_data|
          price_data[:rule].nil? ||
            RuleEngine.match(context: context.to_h, rule: price_data[:rule]).result
        end
      end
    end
  end
end
