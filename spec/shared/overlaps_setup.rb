# frozen_string_literal: true

RSpec.shared_context "with overlaps setup" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:default_group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }
end
