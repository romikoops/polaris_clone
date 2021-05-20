# frozen_string_literal: true

class CorrectLclSacoBillable < ActiveRecord::Migration[5.2]
  def up
    CorrectLclSacoBillableWorker.perform_async
  end
end
