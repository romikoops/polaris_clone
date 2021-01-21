require "rails_helper"
RSpec.describe BackfillTestShipmentsAndQuotationsBillingWorker, type: :worker do
  context "when organization scope has no blacklisted emails" do
    let!(:shipment) { FactoryBot.create(:legacy_shipment, user: test_user, billing: 1) }
    let!(:legacy_quotation) { FactoryBot.create(:legacy_quotation, user: test_user, billing: 1) }
    let!(:quotation) { FactoryBot.create(:quotations_quotation, user: test_user, billing: 1) }
    let!(:quotation_2) { FactoryBot.create(:quotations_quotation, creator: test_user, billing: 1) }
    let(:test_user) { FactoryBot.create(:organizations_user, email: "somebody@itsmycargo.com") }

    it "adds email to blacklist" do
      described_class.new.perform
      [shipment, legacy_quotation, quotation, quotation_2].map(&:reload)
      expect([shipment, legacy_quotation, quotation, quotation_2].map(&:billing).uniq).to eq ["test"]
    end
  end
end
