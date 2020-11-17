# frozen_string_literal: true

require 'rails_helper'

module AddressBook
  RSpec.describe Contact, type: :model do
    let(:contact) { FactoryBot.create(:address_book_contact) }

    it 'Creates a valid contact' do
      expect(contact).to be_valid
    end

    it 'Validates uniqueness of contacts per user in the scope of first_name, last_name, phone, email' do
      repeated_contact = contact.dup

      aggregate_failures do
        expect(repeated_contact).not_to be_valid
        expect(repeated_contact.errors).to include :user_id
      end
    end
  end
end

# == Schema Information
#
# Table name: address_book_contacts
#
#  id               :uuid             not null, primary key
#  city             :string
#  company_name     :string
#  country_code     :string
#  email            :string
#  first_name       :string
#  geocoded_address :string
#  last_name        :string
#  phone            :string
#  point            :geometry         geometry, 0
#  postal_code      :string
#  premise          :string
#  province         :string
#  street           :string
#  street_number    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  old_user_id      :uuid
#  sandbox_id       :uuid
#  tms_id           :string
#  user_id          :uuid
#
# Indexes
#
#  index_address_book_contacts_on_old_user_id  (old_user_id)
#  index_address_book_contacts_on_sandbox_id   (sandbox_id)
#  index_address_book_contacts_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (old_user_id => tenants_users.id)
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
