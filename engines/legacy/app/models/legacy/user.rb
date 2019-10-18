# frozen_string_literal: true

module Legacy
  class User < ApplicationRecord
    self.table_name = 'users'

    include PgSearch::Model
    
    devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable # , :omniauthable

    include DeviseTokenAuth::Concerns::User

    before_validation :set_default_role, :sync_uid, :clear_tokens_if_empty
    before_create :set_default_currency
    validates :tenant_id, presence: true
    validates :email, presence: true, uniqueness: { scope: :tenant_id }
    pg_search_scope :search, against: %i(first_name last_name company_name email phone), using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :email_search, against: %i(email), using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :first_name_search, against: %i(first_name), using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :last_name_search, against: %i(last_name), using: {
      tsearch: { prefix: true }
    }

    acts_as_paranoid

    # Basic associations
    belongs_to :tenant
    belongs_to :role, optional: true, class_name: 'Legacy::Role'

    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    has_many :shipments
    has_many :documents
    has_many :conversations
    has_many :user_addresses, dependent: :destroy
    has_many :addresses, through: :user_addresses

    has_many :receivable_shipments, foreign_key: 'consignee_id'

    has_many :routes, foreign_key: :customer_id

    has_many :contacts
    has_many :consignees, through: :contacts
    has_many :notifyees, through: :contacts

    has_many :user_managers
    has_many :pricings
    has_many :rates, class_name: 'Pricings::Pricing'
    has_one :tenants_user, class_name: 'Tenants::User', foreign_key: 'legacy_id'

    belongs_to :agency, optional: true

    %i(admin shipper super_admin sub_admin agent agency_manager).each do |role_name|
          scope role_name, -> { joins(:role).where("roles.name": role_name) }
    end

    has_paper_trail

    delegate :company, to: :tenants_user

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

    def group_ids
      all_groups.ids
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
#
