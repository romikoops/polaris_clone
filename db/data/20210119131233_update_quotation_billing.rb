# frozen_string_literal: true
class UpdateQuotationBilling < ActiveRecord::Migration[5.2]
  def up
    UpdateQuotationBillingWorker.perform_async
  end
end
