# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_user, class: 'Tenants::User' do
    transient do
      activate { true }
    end

    sequence(:email) { |n| "test#{n}@itsmycargo.test" }
    association :legacy, factory: :legacy_user
    after(:create) do |user, evaluator|
      user.activate! if evaluator.activate
    end
  end
end

# == Schema Information
#
# Table name: tenants_users
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
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  unlock_token                        :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  company_id                          :uuid
#  legacy_id                           :integer
#  sandbox_id                          :uuid
#  tenant_id                           :uuid
#
# Indexes
#
#  index_tenants_users_on_activation_token                     (activation_token)
#  index_tenants_users_on_email_and_tenant_id                  (email,tenant_id) UNIQUE
#  index_tenants_users_on_last_logout_at_and_last_activity_at  (last_logout_at,last_activity_at)
#  index_tenants_users_on_reset_password_token                 (reset_password_token)
#  index_tenants_users_on_sandbox_id                           (sandbox_id)
#  index_tenants_users_on_tenant_id                            (tenant_id)
#  index_tenants_users_on_unlock_token                         (unlock_token)
#
