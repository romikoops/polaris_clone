# frozen_string_literal: true

RSpec.shared_context "offer_calculator_shared_context" do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      organization: organization,
      load_type: load_type,
      custom_cargo_classes: cargo_classes)
  end
  let(:quotation) {
    FactoryBot.create(:quotations_quotation, organization: organization, legacy_shipment_id: shipment.id)
  }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
end
