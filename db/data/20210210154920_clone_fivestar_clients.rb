# frozen_string_literal: true

class CloneFivestarClients < ActiveRecord::Migration[5.2]
  def up
    CloneFivestarClientsWorker.perform_async
  end
end
