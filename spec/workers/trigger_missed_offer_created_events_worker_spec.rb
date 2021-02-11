require "rails_helper"
RSpec.describe TriggerMissedOfferCreatedEventsWorker, type: :worker do
  before do
    [unsent_event, sent_event].each do |event|
      Rails.configuration.event_store.publish(event, stream_name: stream_name)
    end
  end

  let(:unsent_event) do
    Journey::OfferCreated.new(
      data: {offer: offer.to_global_id, organization_id: organization.id},
      metadata: {timestamp: described_class::CUT_OFF_DATE - 2.days}
    )
  end
  let(:sent_event) do
    Journey::OfferCreated.new(
      data: {offer: other_offer.to_global_id, organization_id: organization.id},
      metadata: {timestamp: described_class::CUT_OFF_DATE + 2.days}
    )
  end
  let(:stream_name) { "Organization$#{organization.id}" }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:other_query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:offer) { FactoryBot.create(:journey_offer, query: query) }
  let(:other_offer) { FactoryBot.create(:journey_offer, query: other_query) }
  let(:email) { "test@itsmycargo.com" }
  let!(:subscription) do
    Notifications::Subscription.create(
      email: email,
      organization: organization,
      event_type: "Journey::OfferCreated"
    )
  end
  let(:correct_expected_args) do
    {
      offer: offer,
      organization: organization,
      recipient: subscription.email
    }
  end
  let(:wrong_expected_args) do
    correct_expected_args.merge(offer: other_offer)
  end
  let(:mailer_job) { double(deliver_later: true) }
  let(:mailer_spy) { spy("Notifications::AdminMailer", offer_created: mailer_job) }

  describe "perform" do
    before do
      allow(Notifications::AdminMailer).to receive(:with).and_return(mailer_spy)
      described_class.new.perform
    end

    it "republishes for the past events" do
      expect(Notifications::AdminMailer).to have_received(:with).with(correct_expected_args)
      expect(Notifications::AdminMailer).not_to have_received(:with).with(wrong_expected_args)
    end
  end
end
