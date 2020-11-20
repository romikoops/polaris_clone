# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    company_name { "Example Company" }
    sequence(:first_name) { |n| "John#{n}" }
    sequence(:last_name) { |n| "Smith#{n}" }
    sequence(:phone) { |n| "1234567#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }
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
