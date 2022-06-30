# frozen_string_literal: true

class AddFrenchPostalCodes < ActiveRecord::Migration[5.2]
  def up
    AddFrenchPostalCodesWorker.perform_async
  end
end
