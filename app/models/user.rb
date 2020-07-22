# frozen_string_literal: true

class User < Legacy::User # rubocop:disable Metrics/ClassLength
  include PgSearch::Model
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable # , :omniauthable

  include DeviseTokenAuth::Concerns::User
  before_validation :set_default_role, :sync_uid, :clear_tokens_if_empty
  before_create :set_default_currency

  validates :organization_id, presence: true
  validates :email, presence: true, uniqueness: { scope: :organization_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
  pg_search_scope :search, against: %i[email], using: {
    tsearch: { prefix: true }
  }
  pg_search_scope :email_search, against: %i[email], using: {
    tsearch: { prefix: true }
  }

  # Basic associations
  belongs_to :organization, class_name: 'Organizations::Organization'
  belongs_to :role
  has_many :shipments
  has_many :user_addresses, dependent: :destroy
  has_many :addresses, through: :user_addresses
  has_many :receivable_shipments, foreign_key: 'consignee_id'
  has_many :user_route_discounts
  has_many :routes, foreign_key: :customer_id
  has_many :contacts
  has_many :consignees, through: :contacts
  has_many :notifyees, through: :contacts
  has_many :user_managers

  has_many :rates, class_name: 'Pricings::Pricing'
  has_one :tenants_user, class_name: 'Tenants::User', foreign_key: 'legacy_id'

  belongs_to :agency, optional: true

  %i(admin shipper super_admin sub_admin agent agency_manager).each do |role_name|
    scope role_name, -> { joins(:role).where("roles.name": role_name) }
  end

  PERMITTED_PARAMS = %i(
    email password guest organization_id confirm_password password_confirmation
    company_name vat_number VAT_number first_name last_name phone
    cookies company_number
  ).freeze

  acts_as_paranoid

  # Basic associations
  has_many :documents, class_name: 'Legacy::File', dependent: :destroy

  has_paper_trail

  delegate :company, to: :tenants_user

  # Filterrific
  filterrific default_filter_params: { sorted_by: 'created_at_asc' },
              available_filters: %w[
                sorted_by
                search_query
              ]
  self.per_page = 10 # default for will_paginate

  scope :search_query, lambda { |query|
    return nil if query.blank?

    # condition query, parse into individual keywords
    terms = query.to_s.delete(',').downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # prepend and append '%', remove duplicate '%'s
    terms = terms.map do |e|
      ('%' + e.tr('*', '%') + '%').gsub(/%+/, '%')
    end

    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 3

    or_clauses = [
      'users.first_name ILIKE ?',
      'users.last_name ILIKE ?',
      'users.email ILIKE ?'
    ].join(' OR ')

    where(
      terms.map { "(#{or_clauses})" }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/
      order("users.created_at #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  # Class methods
  def self.options_for_sorted_by
    [
      ['Registration date (newest first)', 'created_at_desc'],
      ['Registration date (oldest first)', 'created_at_asc']
    ]
  end

  def self.clear_tokens
    User.all.each do |u|
      u.tokens = nil
      u.save!
    end
  end

  def sanitized_user(options)
    render_options = {
      except: %i(tokens encrypted_password),
      include: options
    }
    as_json(render_options)
  end

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_and_company
    "#{first_name} #{last_name}, #{company_name}"
  end

  def full_name_and_company_and_address
    "#{first_name} #{last_name}\n#{company_name}\n#{address.geocoded_address}"
  end

  def decorated_created_at
    created_at.to_date.to_s(:long)
  end

  def primary_address
    addresses.where('user_addresses.primary': true).first
  end

  def secondary_addresses
    addresses.where('user_addresses.primary': false)
  end

  def external_id
    self[:external_id] || (role.name != 'agency_manager' && agency&.agency_manager&.external_id)
  end

  # Devise Token Auth override
  def token_validation_response
    as_json(
      except: %i(tokens encrypted_password created_at updated_at role_id),
      include: {
        role: { except: %i(created_at updated_at) }
      },
      methods: [:uuid]
    )
  end

  # Override devise method to include additional info as opts hash
  def send_confirmation_instructions(opts = {})
    return if guest

    generate_confirmation_token! unless @raw_confirmation_token

    # fall back to "default" config name
    opts[:client_config] ||= 'default'
    opts[:redirect_url]  ||= DeviseTokenAuth.default_confirm_success_url
    opts[:to]              = unconfirmed_email if pending_reconfirmation?

    send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
  end

  # Override devise method to use deliver_later
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def has_pricings
    !rates.empty?
  end

  def pricing_id
    role.name == 'agent' ? agency_pricing_id : id
  end

  def agency_pricing_id
    agency&.agency_manager_id
  end

  def for_admin_json(options = {})
    new_options = options.reverse_merge(
      except: %i(tokens encrypted_password created_at updated_at role_id),
      include: {
        role: { except: %i(created_at updated_at) }
      },
      methods: %i(has_pricings group_count user_margin_count company_title uuid)
    )
    as_json(new_options)
  end

  def groups
    ::Organizations::User.find_by(legacy_id: id)&.groups || []
  end

  def company_title
    tenants_user&.company&.name
  end

  def uuid
    tenants_user&.id
  end

  def group_count
    groups&.count
  end

  def user_margins
    ::Pricings::Margin.where(applicable: ::Organizations::User.find_by(legacy_id: id))
  end

  def user_margin_count
    user_margins.count
  end

  def confirm
    update_shipments
    super
  end

  private

  def set_default_role
    self.role ||= Role.find_by_name('shipper')
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

  def update_shipments
    shipments.requested_by_unconfirmed_account.each do |shipment|
      shipment.status = 'requested'
      shipment.save
    end
  end

  protected

  def confirmation_required?
    false
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
