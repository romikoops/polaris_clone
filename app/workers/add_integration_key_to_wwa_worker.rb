# frozen_string_literal: true

class AddIntegrationKeyToWwaWorker
  include Sidekiq::Worker

  WWA_SLUG = "wwa"

  def perform
    wwa_organization = Organizations::Organization.find_by(slug: WWA_SLUG)
    raise StandardError, "Organization with slug : #{WWA_SLUG} not found" if wwa_organization.nil?

    wwa_integration_token = Organizations::IntegrationToken.active.find_by(
      organization_id: wwa_organization.id,
      scope: "pricings.upload"
    )

    return wwa_integration_token if wwa_integration_token.present?

    wwa_integration_token = Organizations::IntegrationToken.new(
      organization_id: wwa_organization.id,
      scope: "pricings.upload",
      description: "Integration token for WWA Organization",
      pipeline: "default",
      token: SecureRandom.uuid
    )
    wwa_integration_token.save!
  end
end
