# frozen_string_literal: true

class SoftdeleteDuplicatePricings < ActiveRecord::Migration[5.2]
  def up
    SoftdeleteDuplicatePricingsWorker.perform_async
  end
end
