# frozen_string_literal: true

FactoryBot.define do
  factory :organizations_user, class: 'Organizations::User', parent: :users_user do
    association :organization, factory: :organizations_organization

    trait :with_profile do
      after(:create) do |user, evaluator|
        create(:profiles_profile, user_id: user.id)
      end
    end

    factory :organizations_user_with_profile, traits: [:with_profile]
  end
end

# == Schema Information
#
# Table name: users_users
#
#  id                                  :uuid             not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  activation_state                    :string
#  activation_token                    :string
#  activation_token_expires_at         :datetime
#  crypted_password                    :string
#  deleted_at                          :datetime
#  email                               :string           not null
#  failed_logins_count                 :integer          default(0)
#  last_activity_at                    :datetime
#  last_login_at                       :datetime
#  last_login_from_ip_address          :string
#  last_logout_at                      :datetime
#  lock_expires_at                     :datetime
#  magic_login_email_sent_at           :datetime
#  magic_login_token                   :string
#  magic_login_token_expires_at        :datetime
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  type                                :string
#  unlock_token                        :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  organization_id                     :uuid
#
# Indexes
#
#  index_users_users_on_activation_token        (activation_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_conflict_organizations  (email,organization_id) UNIQUE WHERE ((type)::text = 'Organizations::User'::text)
#  index_users_users_on_conflict_users          (email) UNIQUE WHERE ((type)::text = 'Users::User'::text)
#  index_users_users_on_email                   (email) WHERE (deleted_at IS NULL)
#  index_users_users_on_magic_login_token       (magic_login_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_organization_id         (organization_id)
#  index_users_users_on_reset_password_token    (reset_password_token) WHERE (deleted_at IS NULL)
#  index_users_users_on_unlock_token            (unlock_token) WHERE (deleted_at IS NULL)
#  users_users_activity                         (last_logout_at,last_activity_at) WHERE (deleted_at IS NULL)
#
