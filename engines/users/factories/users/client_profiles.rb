# frozen_string_literal: true

FactoryBot.define do
  factory :users_client_profile, class: "Users::ClientProfile" do
    first_name { "Guest" }
    sequence(:last_name) { |n| "User #{n}" }
    phone { "081 9847079" }
    sequence(:company_name) { |n| "Guest Company #{n}" }

    user { association(:users_client, profile: instance) }
  end
end

# == Schema Information
#
# Table name: profiles_profiles
#
#  id           :uuid             not null, primary key
#  company_name :string
#  first_name   :string           default(""), not null
#  last_name    :string           default(""), not null
#  phone        :string
#  old_user_id  :uuid
#  user_id      :uuid
#
# Indexes
#
#  index_profiles_profiles_on_old_user_id  (old_user_id)
#  index_profiles_profiles_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (old_user_id => tenants_users.id) ON DELETE => cascade
#
