# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    association :user
    association :address
    company_name { 'Example Company' }
    first_name { 'John' }
    last_name { 'Smith' }
    phone { '1234567' }
    email { 'email@email.com' }
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
