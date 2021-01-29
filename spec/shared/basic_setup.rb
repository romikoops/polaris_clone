# frozen_string_literal: true

RSpec.shared_context "offer_calculator_shared_context" do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, organization: organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
end
