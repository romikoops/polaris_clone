# frozen_string_literal: true

class BackfillShipmentsAndRequests < ActiveRecord::Migration[5.2]
  def up
    BackfillShipmentsAndRequestsWorker.perform_async
  end
end
