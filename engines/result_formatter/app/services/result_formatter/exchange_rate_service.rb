# frozen_string_literal: true

module ResultFormatter
  class ExchangeRateService
    attr_reader :line_items

    def initialize(line_items:)
      @line_items = line_items
    end

    def perform
      currency_map = line_items.each_with_object({}) do |line_item, obj|
        next if line_item.total_currency == base_currency

        obj[line_item.total_currency.downcase] = (1 / line_item.exchange_rate).round(2)
      end
      currency_map.blank? ? currency_map : currency_map.merge("base" => base_currency)
    end

    def base_currency
      @base_currency ||= line_items.first.result.result_set.currency
    end
  end
end
