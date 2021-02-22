# frozen_string_literal: true
class TriggerMissedOfferCreatedEventsWorker
  include Sidekiq::Worker

  CUT_OFF_DATE = Date.parse("2021/02/05")

  def perform(*args)
    client = Rails.configuration.event_store
    Organizations::Organization.where(live: true).find_each do |organization|
      stream_name = "Organization$#{organization.id}"
      events = client.read.stream(stream_name).of_type([Journey::OfferCreated]).to_a
      events.each do |event|
        next if event.metadata[:timestamp] > CUT_OFF_DATE

        Notifications::Subscription.where(
          event_type: "Journey::OfferCreated",
          organization_id: event.data.fetch(:organization_id)
        ).find_each do |subscription|
          send_email(event: event, subscription: subscription)
        end
      end
    end
  end

  def send_email(event:, subscription:)
    offer = GlobalID.find(event.data.fetch(:offer))
    query = offer.query
    Notifications::AdminMailer.with(
      organization: query.organization,
      offer: offer,
      recipient: subscription.email || subscription.user.email
    ).offer_created.deliver_later
  end
end
