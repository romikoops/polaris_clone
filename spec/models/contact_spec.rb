# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  context 'validations' do
    let(:user) { build(:user) }

    let!(:contact_one) { create(:contact, user: user, first_name: 'John', last_name: 'Doe', company_name: 'ACME', email: 'john@example.com', phone: '123456') }
    let(:contact_two) { build(:contact, user: user, first_name: 'John', last_name: 'Doe', company_name: 'ACME', email: 'john@example.com', phone: '123456') }
    let(:contact_three) { build(:contact, user: user, first_name: 'Johnny') }

    context 'Different first names' do
      it 'is validate the uniqueness' do
        expect(contact_one).to be_valid
        expect(contact_three).to be_valid
      end
    end

    context 'Same information' do
      it 'does not validate because they are not unique' do
        expect(contact_two).to be_invalid
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
#  sandbox_id   :uuid
#
