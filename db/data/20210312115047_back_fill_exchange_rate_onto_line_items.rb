class BackFillExchangeRateOntoLineItems < ActiveRecord::Migration[5.2]
  def up
    BackFillExchangeRateOntoLineItemsWorker.perform_async
  end
end
