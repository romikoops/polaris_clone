# frozen_string_literal: true

class RepublishMissedEventsWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    organization = Organizations::Organization.find_by(slug: "lclsaco")
    events = Notifications::EventFilter.new(
      organization: organization,
      type: Journey::OfferCreated,
      period: Range.new(Date.parse("27/05/2022"), Date.parse("14/06/2022"))
    ).perform
    Notifications::EventRepublisher.new(events: events).perform
  end
end
