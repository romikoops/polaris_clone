# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    currency { 'USD' }
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:email) { |n| "demo#{n}@demo.com" }
    password { 'demo123456789' }
    sandbox { false }
    association :tenant
    association :role
    association :optin_status
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  provider               :string           default("tenant_email"), not null
#  uid                    :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  nickname               :string
#  image                  :string
#  email                  :string
#  tenant_id              :integer
#  company_name           :string
#  first_name             :string
#  last_name              :string
#  phone                  :string
#  tokens                 :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role_id                :bigint
#  guest                  :boolean          default(FALSE)
#  currency               :string           default("EUR")
#  vat_number             :string
#  allow_password_change  :boolean          default(FALSE), not null
#  optin_status           :jsonb
#  optin_status_id        :integer
#  external_id            :string
#  agency_id              :integer
#  internal               :boolean          default(FALSE)
#  deleted_at             :datetime
#  sandbox_id             :uuid
#  company_number         :string
#
