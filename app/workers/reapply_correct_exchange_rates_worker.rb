# frozen_string_literal: true

class ReapplyCorrectExchangeRatesWorker
  include Sidekiq::Worker

  def perform
    Journey::ResultSet.where("created_at > ?", DateTime.new(2021, 0o3, 16, 0, 0, 0)).find_each do |result_set|
      bank = bank_for_date(date: result_set.created_at)
      Journey::LineItem.where(line_item_set: result_set.results.flat_map(&:line_item_sets))
        .group_by(&:total_currency)
        .each do |currency, line_items|
          rate = if currency == result_set.currency
            1
          else
            bank.get_rate(currency, result_set.currency)
          end

          Journey::LineItem.where(id: line_items.map(&:id)).update_all(exchange_rate: rate)
        end
    end
  end

  def bank_for_date(date:)
    store = MoneyCache::Converter.new(
      klass: Treasury::ExchangeRate,
      date: date,
      config: { bank_app_id: Settings.open_exchange_rate&.app_id || "" }
    )
    Money::Bank::VariableExchange.new(store)
  end
end
