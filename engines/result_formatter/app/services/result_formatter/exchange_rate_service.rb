# frozen_string_literal: true

module ResultFormatter
  class ExchangeRateService
    attr_reader :line_items

    def initialize(line_items:)
      @line_items = line_items
    end

    def perform
      currency_map = line_items.group_by(&:total_currency).each_with_object({}) do |(currency, currency_line_items), obj|
        next if currency == base_currency

        decimal_count = [currency_line_items.max_by(&:total_cents).total_cents.to_s.length, 6].max
        obj[currency.downcase] = (1 / currency_line_items.first.exchange_rate).round(decimal_count)
      end
      currency_map.blank? ? currency_map : currency_map.merge("base" => base_currency)
    end

    def base_currency
      @base_currency ||= line_items.first.result.query.currency
    end
  end
end
