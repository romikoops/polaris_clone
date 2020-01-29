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
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#  tenant_id  :integer
#
# Indexes
#
#  index_trucking_couriers_on_sandbox_id  (sandbox_id)
#  index_trucking_couriers_on_tenant_id   (tenant_id)
#
