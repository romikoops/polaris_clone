# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe LocalCharge, type: :model do
    describe ".deleted_at" do
      it "soft deletes a LocalCharge, by checking the deleted_at value is present" do
        organization = FactoryBot.create(:organizations_organization)
        FactoryBot.create(:legacy_local_charge, organization: organization)
        described_class.last.destroy
        expect(described_class.with_deleted.last.deleted_at).to be_present
      end
    end
  end
end
