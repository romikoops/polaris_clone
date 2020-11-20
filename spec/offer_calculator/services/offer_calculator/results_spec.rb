# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Results do
  ActiveJob::Base.queue_adapter = :test

  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      organization: organization)
  end

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:results) {
    described_class.new(shipment: shipment, quotation: quotation, wheelhouse: false, mailer: "QuoteMailer")
  }
  let(:mailer) { class_double("QuoteMailer").as_stubbed_const(transfer_nested_constants: true) }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope, target: organization, content: {email_all_quotes: true})
    message_delivery = instance_double(ActionMailer::MessageDelivery)
    allow(mailer).to receive(:new_quotation_admin_email).and_return(message_delivery)
    allow(message_delivery).to receive(:deliver_later)
  end

  describe "send admin mailer" do
    it "sends an email when scope settings are correct" do
      results.send(:send_admin_email)
      expect(mailer).to have_received(:new_quotation_admin_email).at_least(1).times
    end
  end
end
