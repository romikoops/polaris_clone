# frozen_string_literal: true

module Tenants
  class User < ApplicationRecord
    include ::Tenants::Legacy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :legacy, class_name: 'Legacy::User', optional: true
    has_one :scope, as: :target, class_name: 'Tenants::Scope'
    belongs_to :tenant, optional: true
    belongs_to :company, optional: true, class_name: 'Tenants::Company'
    has_many :memberships, as: :member, dependent: :destroy
    has_many :groups, through: :memberships, as: :member
    has_many :margins, as: :applicable
    validates :email, presence: true, uniqueness: { scope: :tenant_id }
    authenticates_with_sorcery!

    has_paper_trail
    acts_as_paranoid

    def all_groups
      membership_ids = [memberships.pluck(:group_id), company&.memberships&.pluck(:group_id)].compact.flatten
      ::Tenants::Group.where(id: membership_ids)
    end

    def verify_company
      return if company_id

      company_id = ::Tenants::Company.find_by(
        name: legacy&.company_name,
        tenant_id: tenant_id
      )&.id
      company_id ||= ::Tenants::Company.find_or_create_by(
        name: legacy&.company_name,
        vat_number: legacy&.vat_number,
        tenant_id: tenant_id
      )&.id
      update(company_id: company_id)
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
