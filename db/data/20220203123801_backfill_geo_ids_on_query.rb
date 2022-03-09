# frozen_string_literal: true

class BackfillGeoIdsOnQuery < ActiveRecord::Migration[5.2]
  def up
    BackfillGeoIdsOnQueryWorker.perform_async
  end
end
