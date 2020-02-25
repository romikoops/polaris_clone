# frozen_string_literal: true

FactoryBot.define do
  factory :profiles_profile, class: 'Profiles::Profile' do
    first_name { 'Guest' }
    sequence(:last_name) { |n| "User #{n}" }
    phone { '081 9847079' }
    sequence(:company_name) { |n| "Guest Company #{n}" }
  end
end

# == Schema Information
#
# Table name: profiles_profiles
#
#  id           :uuid             not null, primary key
#  company_name :string
#  first_name   :string
#  last_name    :string
#  phone        :string
#  user_id      :uuid
#
# Indexes
#
#  index_profiles_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => tenants_users.id) ON DELETE => cascade
#
