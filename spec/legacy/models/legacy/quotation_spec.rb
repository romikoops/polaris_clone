# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Quotation, type: :model do
    describe 'it creates a valid object' do
      it 'is valid' do
        expect(FactoryBot.build(:legacy_quotation)).to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  target_email         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  distinct_id          :uuid
#  old_user_id          :integer
#  original_shipment_id :integer
#  sandbox_id           :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_quotations_on_sandbox_id  (sandbox_id)
#  index_quotations_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_  (user_id => users_users.id)
#
