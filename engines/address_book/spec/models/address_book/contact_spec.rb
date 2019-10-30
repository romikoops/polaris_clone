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
      expect(repeated_contact).to_not be_valid
      expect(repeated_contact.errors).to include :user_id
    end
  end
end
