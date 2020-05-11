# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    currency { 'USD' }
    sequence(:email) { |n| "demo#{n}@demo.com" }
    password { 'demo123456789' }
    sandbox { false }
    association :tenant
    association :role

    transient do
      with_profile { false }
      first_name { 'Guest' }
      last_name { 'User' }
    end

    after(:create) do |user, evaluator|
      evaluator.with_profile && create(:profiles_profile,
                                       first_name: evaluator.first_name,
                                       last_name: evaluator.last_name,
                                       user_id: Tenants::User.find_by(legacy_id: user.id).id)
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                                         :bigint           not null, primary key
#  allow_password_change                      :boolean          default(FALSE), not null
#  company_name_20200207                      :string
#  company_number                             :string
#  confirmation_sent_at                       :datetime
#  confirmation_token                         :string
#  confirmed_at                               :datetime
#  currency                                   :string           default("EUR")
#  current_sign_in_at                         :datetime
#  current_sign_in_ip                         :string
#  deleted_at                                 :datetime
#  email(MASKED WITH EmailAddress)            :string
#  encrypted_password                         :string           default(""), not null
#  first_name_20200207(MASKED WITH FirstName) :string
#  guest                                      :boolean          default(FALSE)
#  image                                      :string
#  internal                                   :boolean          default(FALSE)
#  last_name_20200207(MASKED WITH LastName)   :string
#  last_sign_in_at                            :datetime
#  last_sign_in_ip                            :string
#  nickname                                   :string
#  optin_status                               :jsonb
#  phone_20200207(MASKED WITH Phone)          :string
#  provider                                   :string           default("tenant_email"), not null
#  remember_created_at                        :datetime
#  reset_password_sent_at                     :datetime
#  reset_password_token                       :string
#  sign_in_count                              :integer          default(0), not null
#  tokens                                     :json
#  uid                                        :string           default(""), not null
#  unconfirmed_email                          :string
#  vat_number                                 :string
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  agency_id                                  :integer
#  external_id                                :string
#  optin_status_id                            :integer
#  role_id                                    :bigint
#  sandbox_id                                 :uuid
#  tenant_id                                  :integer
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role_id               (role_id)
#  index_users_on_sandbox_id            (sandbox_id)
#  index_users_on_tenant_id             (tenant_id)
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#
