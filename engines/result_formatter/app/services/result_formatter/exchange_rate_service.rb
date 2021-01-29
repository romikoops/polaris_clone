# frozen_string_literal: true

module ResultFormatter
  class ExchangeRateService
    attr_reader :base_currency, :currencies, :timestamp

    def initialize(base_currency:, currencies:, timestamp: Time.zone.now)
      @base_currency = base_currency
      @currencies = currencies
      @timestamp = timestamp
    end

    def perform
      currency_map = currencies.each_with_object({}) { |currency, obj|
        next if currency == base_currency

        obj[currency.downcase] = bank.get_rate(base_currency, currency)
      }
      currency_map.blank? ? currency_map : currency_map.merge("base" => base_currency)
    end

    private

    def bank
      app_id = Settings.open_exchange_rate&.app_id || ""
      @bank ||= MoneyCache::Converter.new(
        klass: Treasury::ExchangeRate,
        date: timestamp,
        config: {bank_app_id: app_id}
      )
    end
  end
end
