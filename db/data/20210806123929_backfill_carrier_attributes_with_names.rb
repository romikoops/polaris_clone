# frozen_string_literal: true

class BackfillCarrierAttributesWithNames < ActiveRecord::Migration[5.2]
  def up
    BackfillCarrierAttributesWithNamesWorker.perform_async
  end
end
