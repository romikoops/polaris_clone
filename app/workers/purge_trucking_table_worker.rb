# frozen_string_literal: true

class PurgeTruckingTableWorker
  include Sidekiq::Worker
  SLUGS_TO_SAVE = %w[unsworth
    berkman
    esser
    pcs
    yourdemo
    wwa
    beweship
    lclsaco
    gateway
    petlogistics
    demo
    berger
    fivestar-nl
    fivestar-be
    fivestar].freeze

  def perform
    ActiveRecord::Base.connection.execute("
      DELETE FROM trucking_truckings
      USING organizations_organizations
      WHERE organizations_organizations.id = trucking_truckings.organization_id
      AND organizations_organizations.slug IN ('#{SLUGS_TO_SAVE.join("', '")}')
      AND UPPER(validity) < now()
    ")
    ActiveRecord::Base.connection.execute("
      DELETE FROM trucking_truckings
      USING organizations_organizations
      WHERE organizations_organizations.id = trucking_truckings.organization_id
      AND organizations_organizations.slug NOT IN ('#{SLUGS_TO_SAVE.join("', '")}')
    ")
    ActiveRecord::Base.connection.execute("DELETE FROM trucking_truckings WHERE deleted_at IS NOT NULL")
    ActiveRecord::Base.connection.execute("VACUUM ANALYZE trucking_truckings;") unless Rails.env.test?
  end
end
