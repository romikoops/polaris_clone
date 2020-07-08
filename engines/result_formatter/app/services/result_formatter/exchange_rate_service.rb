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

        obj[currency.downcase] = bank.get_rate(base_currency, currency)
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

    def bank
      return Money.default_bank if (5.minutes.ago...Time.now).cover?(tender.created_at)

      app_id = Settings.open_exchange_rate&.app_id || ""
      @bank ||= MoneyCache::Converter.new(
        klass: Legacy::ExchangeRate,
        date: tender.created_at,
        config: {bank_app_id: app_id}
      )
    end
  end
end
