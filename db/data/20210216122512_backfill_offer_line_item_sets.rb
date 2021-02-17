# frozen_string_literal: true

class BackfillOfferLineItemSets < ActiveRecord::Migration[5.2]
  def up
    BackfillOfferLineItemSetsWorker.perform_async
  end
end
