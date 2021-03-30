# frozen_string_literal: true

class ReapplyCorrectExchangeRates < ActiveRecord::Migration[5.2]
  def up
    ReapplyCorrectExchangeRatesWorker.perform_async
  end
end
