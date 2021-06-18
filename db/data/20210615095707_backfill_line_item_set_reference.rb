# frozen_string_literal: true

class BackfillLineItemSetReference < ActiveRecord::Migration[5.2]
  def up
    BackfillLineItemSetReferenceWorker.perform_async
  end
end
