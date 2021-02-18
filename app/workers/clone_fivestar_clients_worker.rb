# frozen_string_literal: true

class CloneFivestarClientsWorker
  include Sidekiq::Worker

  def perform(*args)
    fivestar = Organizations::Organization.find_by(slug: "fivestar")
    OrganizationManager::ClientSynchronizerService.new(
      organization: fivestar,
      target_organizations: Organizations::Organization.where(slug: ["fivestar-be", "fivestar-nl"]),
      emails: Users::Client.global.where(organization: fivestar).select(:email)
    ).perform
  end
end
