# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentService::GdprWriter do
  context ".perform" do
    subject { described_class.new(user_id: user.id) }

    subject(:writer) { described_class.new(user_id: user.id) }

    let(:user) { FactoryBot.create(:users_client) }
    let(:profile) { user.profile }
    let!(:contact) { FactoryBot.create(:legacy_contact, user: user) }
    let!(:shipment) {
      FactoryBot.create(:complete_legacy_shipment, user: user, with_breakdown: true, with_tenders: true)
    }

    before do
      ::Organizations.current_id = user.organization_id
    end

    it "creates file" do
      expect(subject).to receive(:write_to_aws)
        .with("tmp/#{profile.name}_GDPR.xlsx", user.organization, "#{profile.name}_GDPR.xlsx", "gdpr")
        .and_return("http://AWS")

      expect(subject.perform).to eq("http://AWS")
    end

    it "creates file in db" do
      aggregate_failures do
        expect(writer.perform).to include("#{URI.encode(profile.name)}_GDPR.xlsx")
        expect(Legacy::File.count).to eq(1)
      end
    end
  end
end
