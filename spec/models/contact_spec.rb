# frozen_string_literal: true

require 'rails_helper'

describe Contact, type: :model do
  context 'validations' do
    let(:user) { build(:user) }

    let!(:contact_one) { create(:contact, user: user) }
    let(:contact_two) { build(:contact, user: user) }
    let(:contact_three) { build(:contact, user: user, first_name: 'Johnny') }

    context 'Different first names' do
      it 'is validate the uniqueness' do
        contact_one.should be_valid
        contact_three.should be_valid
      end
    end

    context 'Same information' do
      it 'does not validate because they are not unique' do
        contact_two.should be_invalid
      end
    end
  end
end

# == Schema Information
#
# Table name: contacts
#
#  id           :bigint(8)        not null, primary key
#  user_id      :integer
#  address_id   :integer
#  company_name :string
#  first_name   :string
#  last_name    :string
#  phone        :string
#  email        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  alias        :boolean          default(FALSE)
#
