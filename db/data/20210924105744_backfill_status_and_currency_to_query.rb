# frozen_string_literal: true

class BackfillStatusAndCurrencyToQuery < ActiveRecord::Migration[5.2]
  def up
    BackfillStatusAndCurrencyToQueryWorker.perform_async
  end
end
