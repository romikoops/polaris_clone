# frozen_string_literal: true

module Tenants
  class User < ApplicationRecord
    include ::Tenants::Legacy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :legacy, class_name: 'Legacy::User', optional: true
    has_one :scope, as: :target, class_name: 'Tenants::Scope'
    belongs_to :tenant, optional: true
    belongs_to :company, optional: true, class_name: 'Tenants::Company'
    has_many :memberships, as: :member
    has_many :groups, through: :memberships, as: :member
    has_many :margins, as: :applicable
    validates :email, presence: true, uniqueness: { scope: :tenant_id }
    authenticates_with_sorcery!

    has_paper_trail

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
#  access_count_to_reset_password_page :integer          default(0)
#  last_login_at                       :datetime
#  last_logout_at                      :datetime
#  last_activity_at                    :datetime
#  last_login_from_ip_address          :string
#  failed_logins_count                 :integer          default(0)
#  lock_expires_at                     :datetime
#  unlock_token                        :string
#  legacy_id                           :integer
#  tenant_id                           :uuid
#  company_id                          :uuid
#  sandbox_id                          :uuid
#
