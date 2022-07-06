# frozen_string_literal: true

class BackfillTruckingLocationIdentifier < ActiveRecord::Migration[5.2]
  def up
    BackfillTruckingLocationIdentifierWorker.perform_async
  end
end
