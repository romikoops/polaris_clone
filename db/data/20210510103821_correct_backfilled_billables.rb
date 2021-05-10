# frozen_string_literal: true

class CorrectBackfilledBillables < ActiveRecord::Migration[5.2]
  def up
    CorrectBackfilledBillablesWorker.perform_async
  end
end
