# frozen_string_literal: true

module Tenants
  class User < ApplicationRecord
    include ::Tenants::Legacy

    belongs_to :legacy, class_name: '::User', optional: true
    belongs_to :tenant, optional: true

    validates :email, presence: true, uniqueness: { scope: :tenant_id }
    authenticates_with_sorcery!

    has_paper_trail
  end
end

# == Schema Information
#
# Table name: tenants_users
#
#  id                                  :uuid             not null, primary key
#  email                               :string           not null
#  crypted_password                    :string
#  salt                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  activation_state                    :string
#  activation_token                    :string
#  activation_token_expires_at         :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  reset_password_email_sent_at        :datetime
#  access_count_to_reset_password_page :integer
#  last_login_at                       :datetime
#  last_logout_at                      :datetime
#  last_activity_at                    :datetime
#  last_login_from_ip_address          :string
#  failed_logins_count                 :integer          default(0)
#  lock_expires_at                     :datetime
#  unlock_token                        :string
#  legacy_id                           :integer
#  tenant_id                           :uuid
#
