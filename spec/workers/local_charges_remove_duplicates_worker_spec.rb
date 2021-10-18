# frozen_string_literal: true

require "rails_helper"

RSpec.describe LocalChargesRemoveDuplicatesWorker, type: :worker do
  describe "#perform" do
    context "when there is a duplicate" do
      let!(:local_charge) { create_local_charge }
      let(:duplicated_local_charge) { local_charge.dup }

      it "soft deletes the local charge", :aggregate_failures do
        duplicated_local_charge.save!
        described_class.new.perform
        expect(local_charge.deleted_at).to be_blank
        expect(duplicated_local_charge.reload.deleted_at).to be_present
      end
    end

    context "when the previous local charge's validity, covers the current local charge" do
      let!(:duplicated_local_charge) { create_local_charge }
      let!(:local_charge) do
        local_charge = duplicated_local_charge.dup.tap do |lc|
          lc.effective_date = duplicated_local_charge.effective_date + 1.week
          lc.expiration_date = duplicated_local_charge.expiration_date - 1.week
          lc.created_at = duplicated_local_charge.created_at + 5.seconds
        end
        local_charge.save!
        local_charge
      end

      it "updates the local charge's expiration date" do
        described_class.new.perform
        expect(duplicated_local_charge.reload.expiration_date.end_of_day).to eq((local_charge.effective_date - 1.day).end_of_day)
      end
    end

    def create_local_charge(options = {})
      FactoryBot.create(:legacy_local_charge, options.merge(organization: FactoryBot.create(:organizations_organization)))
    end
  end
end
