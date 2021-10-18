# frozen_string_literal: true

class LocalChargesRemoveDuplicates < ActiveRecord::Migration[5.2]
  def up
    LocalChargesRemoveDuplicatesWorker.perform_async
  end
end
