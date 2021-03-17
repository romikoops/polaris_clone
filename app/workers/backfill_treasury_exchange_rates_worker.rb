class BackfillTreasuryExchangeRatesWorker
  include Sidekiq::Worker

  def perform(*args)
    ActiveRecord::Base.connection.execute('
      INSERT INTO treasury_exchange_rates (
        id, "from", "to", rate, created_at, updated_at
      )
      SELECT gen_random_uuid(), exchange_rates.from, exchange_rates.to, exchange_rates.rate, exchange_rates.created_at, exchange_rates.updated_at
      FROM exchange_rates
    ')
  end
end
