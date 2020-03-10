# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe UserAddress, type: :model do
    let(:user) { FactoryBot.create(:legacy_user) }
    let(:primary_user_address) { FactoryBot.create(:legacy_user_address, primary: true, user: user) }

    describe 'validity' do
      it 'is a valid user address' do
        expect(primary_user_address).to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: user_addresses
#
#  id         :bigint           not null, primary key
#  category   :string
#  deleted_at :datetime
#  primary    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  address_id :integer
#  user_id    :integer
#
# Indexes
#
#  index_user_addresses_on_deleted_at  (deleted_at)
#
