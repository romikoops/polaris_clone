class BackfillTestShipmentsAndQuotationsBilling < ActiveRecord::Migration[5.2]
  def up
    BackfillTestShipmentsAndQuotationsBillingWorker.perform_async
  end
end
