require 'rails_helper'

module Trucking
  RSpec.describe Courier, type: :model do
    context 'validations' do
      let(:courier) { FactoryBot.create(:trucking_courier) }
      it 'is valid with valid attributes' do
        expect(FactoryBot.build(:trucking_courier)).to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: trucking_couriers
#
#  id              :uuid             not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_trucking_couriers_on_organization_id  (organization_id)
#  index_trucking_couriers_on_sandbox_id       (sandbox_id)
#  index_trucking_couriers_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
