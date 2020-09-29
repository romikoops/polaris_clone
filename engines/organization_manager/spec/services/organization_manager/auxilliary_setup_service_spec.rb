require "rails_helper"

RSpec.describe OrganizationManager::AuxilliarySetupService do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  before do
    FactoryBot.create(:legacy_cargo_item_type, description: "Pallet")
    described_class.new(organization: organization).perform
  end

  describe "#perform" do
    it "creates the minum data required to function" do
      expect(Legacy::MaxDimensionsBundle.exists?(organization: organization)).to be_truthy
      expect(Legacy::TenantCargoItemType.exists?(organization: organization)).to be_truthy
    end
  end
end
