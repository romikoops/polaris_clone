# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contact, type: :model do
  context "validations" do
    let(:user) { FactoryBot.build(:organizations_user) }

    let!(:contact_one) {
      FactoryBot.create(:contact,
        user: user, first_name: "John", last_name: "Doe", company_name: "ACME",
        email: "john@example.com", phone: "123456")
    }
    let(:contact_two) {
      FactoryBot.build(:contact,
        user: user, first_name: "John", last_name: "Doe", company_name: "ACME",
        email: "john@example.com", phone: "123456")
    }
    let(:contact_three) {
      FactoryBot.build(:contact, user: user, first_name: "Johnny")
    }

    context "Different first names" do
      it "is validate the uniqueness" do
        expect(contact_one).to be_valid
        expect(contact_three).to be_valid
      end
    end

    context "Same information" do
      it "does not validate because they are not unique" do
        expect(contact_two).to be_invalid
      end
    end
  end
end

# == Schema Information
#
# Table name: contacts
#
#  id                                :bigint           not null, primary key
#  alias                             :boolean          default(FALSE)
#  company_name                      :string
#  email(MASKED WITH EmailAddress)   :string
#  first_name(MASKED WITH FirstName) :string
#  last_name(MASKED WITH LastName)   :string
#  phone(MASKED WITH Phone)          :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  address_id                        :integer
#  old_user_id                       :integer
#  sandbox_id                        :uuid
#  user_id                           :uuid
#
# Indexes
#
#  index_contacts_on_sandbox_id  (sandbox_id)
#  index_contacts_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_  (user_id => users_users.id)
#
