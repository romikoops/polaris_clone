# frozen_string_literal: true

module ResultFormatter
  class ExchangeRateService
    attr_reader :tender

    def initialize(tender:)
      @tender = tender
    end

    def perform
      currency_map = currencies.each_with_object({}) { |currency, obj|
        next if currency == base_currency

        exchange_relation = Legacy::ExchangeRate
          .where("created_at < ?", tender.created_at)
          .where(from: base_currency, to: currency)
        rate = exchange_relation.order(created_at: :desc).first&.rate
        obj[currency.downcase] = rate
      }
      currency_map.blank? ? currency_map : currency_map.merge("base" => base_currency)
    end

    private

    def base_currency
      @base_currency ||= tender.amount.currency.iso_code
    end

    def currencies
      @currencies ||= tender.line_items.pluck(:amount_currency).uniq
    end
  end
end
