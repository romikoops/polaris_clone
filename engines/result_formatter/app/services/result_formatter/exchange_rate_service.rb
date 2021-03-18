# frozen_string_literal: true

module ResultFormatter
  class ExchangeRateService
    attr_reader :base_currency, :line_items

    def initialize(base_currency:, line_items:)
      @base_currency = base_currency
      @line_items = line_items
    end

    def perform
      currency_map = line_items.each_with_object({}) { |line_item, obj|
        next if line_item.total_currency == base_currency

        obj[line_item.total_currency.downcase] = line_item.exchange_rate
      }
      currency_map.blank? ? currency_map : currency_map.merge("base" => base_currency)
    end
  end
end
