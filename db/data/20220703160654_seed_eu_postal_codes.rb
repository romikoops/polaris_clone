# frozen_string_literal: true

class SeedEuPostalCodes < ActiveRecord::Migration[5.2]
  def up
    SeedEuPostalCodesWorker.perform_async
  end
end
