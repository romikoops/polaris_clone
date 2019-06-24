# frozen_string_literal: true

module Legacy
  class User < ApplicationRecord
    self.table_name = 'users'
    has_paper_trail
    before_validation :set_default_role, :sync_uid, :clear_tokens_if_empty
    belongs_to :tenant
    belongs_to :role, optional: true, class_name: 'Legacy::Role'
    belongs_to :agency, optional: true

    def tenant_scope
      ::Tenants::ScopeService.new(target: self, tenant: tenants_user&.tenant).fetch
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def full_name_and_company
      "#{first_name} #{last_name}, #{company_name}"
    end

    def full_name_and_company_and_address
      "#{first_name} #{last_name}\n#{company_name}\n#{address.geocoded_address}"
    end

    def all_groups
      tenants_user.all_groups
    end

    private

    def set_default_role
      self.role ||= Legacy::Role.find_by_name('shipper')
    end

    def set_default_currency
      self.currency = tenant.currency
    end

    def clear_tokens_if_empty
      self.tokens = nil if tokens == '{}'
    end

    def sync_uid
      self.uid = "#{tenant.id}***#{email}"
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
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
#  role_id                :bigint(8)
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
#
