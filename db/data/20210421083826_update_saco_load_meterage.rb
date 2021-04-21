# frozen_string_literal: true

class UpdateSacoLoadMeterage < ActiveRecord::Migration[5.2]
  def up
    UpdateSacoLoadMeterageWorker.perform_async
  end
end
