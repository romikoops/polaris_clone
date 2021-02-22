# frozen_string_literal: true
class RunExchangeRateUpdateWorkerOnce < ActiveRecord::Migration[5.2]
  def up
    ExchangeRateUpdateWorker.perform_async
  end
end
