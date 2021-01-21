class UpdateQuotationBilling < ActiveRecord::Migration[5.2]
  def up
    UpdateQuotationBillingWorker.perform_async
  end
end
