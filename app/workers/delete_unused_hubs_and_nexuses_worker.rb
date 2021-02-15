# frozen_string_literal: true

class DeleteUnusedHubsAndNexusesWorker
  include Sidekiq::Worker

  def perform(*args)
    Legacy::Hub.where(hub_code: nil).destroy_all
    Legacy::Nexus.where(locode: nil).destroy_all
  end
end
