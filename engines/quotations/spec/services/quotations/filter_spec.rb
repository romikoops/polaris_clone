# frozen_string_literal: true

require "rails_helper"

RSpec.describe Quotations::Filter do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client) }

  describe "#perform" do
    context "when filtering by organization" do
      let(:filter) { described_class.new(organization: organization, start_date: nil, end_date: nil) }
      let(:organization_2) { FactoryBot.create(:organizations_organization) }
      let(:sorted_quotations) { Quotations::Quotation.where(organization: organization).order(:selected_date) }

      before do
        FactoryBot.create_list(:legacy_shipment, 2, with_breakdown: true, with_tenders: true,
                                                    organization_id: organization.id, user: user)
        FactoryBot.create_list(:legacy_shipment, 1, with_breakdown: true, with_tenders: true,
                                                    organization_id: organization_2.id, user: user)
      end

      it "returns filtered results" do
        expect(filter.perform.ids).to match sorted_quotations.ids
      end
    end

    context "when filtering by dates" do
      before do
        FactoryBot.create_list(:legacy_shipment, 5, with_breakdown: true, with_tenders: true,
                                                    organization_id: organization.id)

        Quotations::Quotation.all.each_with_index do |quotation, index|
          quotation.update(selected_date: index.days.ago)
        end
      end

      it "filters by start date" do
        filter = described_class.new(organization: organization, start_date: 5.days.ago, end_date: nil)

        expect(filter.perform.count).to eq 5
      end

      it "filters by end date" do
        filter = described_class.new(organization: organization, start_date: nil, end_date: 2.days.ago)

        expect(filter.perform.count).to eq 3
      end

      it "filters by start and end date" do
        filter = described_class.new(organization: organization, start_date: 3.days.ago, end_date: 2.days.ago)

        expect(filter.perform.count).to eq 1
      end
    end
  end
end
