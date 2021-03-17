class BackfillTreasuryExchangeRates < ActiveRecord::Migration[5.2]
  def up
    BackfillTreasuryExchangeRatesWorker.perform_async
  end
end
