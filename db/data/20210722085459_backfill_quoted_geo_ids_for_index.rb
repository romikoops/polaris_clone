# frozen_string_literal: true

class BackfillQuotedGeoIdsForIndex < ActiveRecord::Migration[5.2]
  def up
    BackfillQuotedGeoIdsForIndexWorker.perform_async
  end
end
