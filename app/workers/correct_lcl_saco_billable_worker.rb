# frozen_string_literal: true

class CorrectLclSacoBillableWorker
  include Sidekiq::Worker

  def perform
    organization = Organizations::Organization.find_by(slug: "lclsaco")
    blacklisted_users = Users::Client.global.where(email: organization.scope.blacklisted_emails, organization: organization)
    # rubocop:disable Rails/SkipsModelValidations
    Journey::Query.joins(:result_sets).where(organization: organization, journey_result_sets: { status: "completed" }).where.not(client: blacklisted_users)
      .where("journey_queries.created_at::date >= ? ", Date.parse("2020-08-16"))
      .update_all(billable: true)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
