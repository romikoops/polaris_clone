module Organizations
  class BackfillLiveOrganizationsWorker
    include Sidekiq::Worker

    def perform(*args)
      live_organization_slugs = [
        "fivestar",
        "gateway",
        "racingcargo",
        "7connetwork",
        "unsworth",
        "lclsaco",
        "saco",
        "esser"
      ]
      Organizations::Organization.where(slug: live_organization_slugs).update_all(live: true)
      Organizations::Organization.where.not(slug: live_organization_slugs).update_all(live: false)
    end
  end
end
