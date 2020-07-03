# frozen_string_literal: true

module Legacy
  class User < ApplicationRecord
    self.table_name = 'users'

    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable,
           :confirmable

    include DeviseTokenAuth::Concerns::User

    before_validation :set_default_role, :sync_uid, :clear_tokens_if_empty

    validates :email, presence: true, uniqueness: { scope: :organization_id }, format: { with: URI::MailTo::EMAIL_REGEXP }

    belongs_to :role, optional: true, class_name: 'Legacy::Role'
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    has_many :user_addresses, class_name: 'Legacy::UserAddress', dependent: :destroy
    has_many :addresses, class_name: 'Legacy::Address', through: :user_addresses
    has_many :files, class_name: 'Legacy::File', dependent: :destroy
    has_many :documents
    deprecate documents: 'Migrated to Legacy::File'
    belongs_to :agency, class_name: 'Legacy::Agency', optional: true
    has_one :tenants_user, class_name: 'Tenants::User', foreign_key: :legacy_id
    delegate :company, to: :tenants_user
    accepts_nested_attributes_for :addresses

    acts_as_paranoid

    def pricing_id
      role&.name == 'agent' ? agency_pricing_id : id
    end

    delegate :all_groups, to: :tenants_user

    def group_ids
      all_groups.ids
    end

    def company_name
      return self[:company_name] unless self[:company_name].nil?

      agency.try(:name)
    end

    private

    def set_default_role
      self.role ||= Legacy::Role.find_by(name: 'shipper')
    end

    def clear_tokens_if_empty
      self.tokens = nil if tokens == '{}'
    end

    def sync_uid
      self.uid = "#{tenant.id}***#{email}"
    end

    def agency_pricing_id
      agency&.agency_manager_id
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  allow_password_change  :boolean          default(FALSE), not null
#  company_name_20200207  :string
#  company_number         :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  currency               :string           default("EUR")
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  deleted_at             :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  first_name_20200207    :string
#  guest                  :boolean          default(FALSE)
#  image                  :string
#  internal               :boolean          default(FALSE)
#  last_name_20200207     :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  nickname               :string
#  optin_status           :jsonb
#  phone_20200207         :string
#  provider               :string           default("tenant_email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  vat_number             :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  agency_id              :integer
#  external_id            :string
#  optin_status_id        :integer
#  organization_id        :uuid
#  role_id                :bigint
#  sandbox_id             :uuid
#  tenant_id              :integer
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email)
#  index_users_on_organization_id       (organization_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role_id               (role_id)
#  index_users_on_sandbox_id            (sandbox_id)
#  index_users_on_tenant_id             (tenant_id)
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (role_id => roles.id)
#
