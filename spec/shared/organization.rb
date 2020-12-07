# frozen_string_literal: true

RSpec.shared_context "organization" do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:scope_content) { {show_chargeable_weight: true, values: {weight: {unit: "kg", decimals: 3}}} }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope, target: organization, content: scope_content)
  end
end
