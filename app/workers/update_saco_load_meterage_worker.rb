# frozen_string_literal: true

class UpdateSacoLoadMeterageWorker
  include Sidekiq::Worker

  def perform
    # rubocop:disable Rails/SkipsModelValidations
    Trucking::Trucking.where(organization: Organizations::Organization.find_by(slug: "lclsaco")).update_all(
      load_meterage: {
        stackable_type: "volume",
        non_stackable_type: "ldm",
        stackable_limit: 35,
        non_stackable_limit: 2.4,
        hard_limit: true
      }
    )
    # rubocop:enable Rails/SkipsModelValidations
  end
end
