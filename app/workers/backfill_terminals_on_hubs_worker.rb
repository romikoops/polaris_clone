# frozen_string_literal: true

class BackfillTerminalsOnHubsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  NAME_TO_SKIP = "BGN/PCGN1956 - HAMAD" # This is the only non terminal name that matches the pattern

  def perform
    target_hubs = Legacy::Hub.where("terminal IS NULL AND name ILIKE ?", "% - %").where.not(name: NAME_TO_SKIP)
    total_hubs = target_hubs.count
    total total_hubs

    target_hubs.find_each.with_index do |hub, index|
      at (index + 1), "Correcting #{hub.name} - #{index + 1}/#{total_hubs}"

      name, terminal = hub.name.split(" - ")

      hub.update!(name: name, terminal: terminal)
    end
  end
end
