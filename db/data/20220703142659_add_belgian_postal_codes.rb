# frozen_string_literal: true

class AddBelgianPostalCodes < ActiveRecord::Migration[5.2]
  def up
    AddBelgianPostalCodesWorker.perform_async
  end
end
