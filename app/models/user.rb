class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable #, :omniauthable

  include DeviseTokenAuth::Concerns::User
  before_validation :set_default_role, :sync_uid, :clear_tokens_if_empty
  before_create :set_default_currency

  validates :tenant_id, presence: true
  validates :email, presence: true, uniqueness: {
    scope: :tenant_id,
    message: -> obj, _ { "'#{obj.email}' taken for Tenant '#{obj.tenant.subdomain}'" }
  }

  # Basic associations
  belongs_to :tenant
  belongs_to :role
  has_many :conversations
  has_many :user_locations, dependent: :destroy
  has_many :locations, through: :user_locations
  has_many :documents
  has_many :shipments
  has_many :receivable_shipments, foreign_key: "consignee_id"

  # belongs_to :notifying_shipment, class_name: "Shipment"

  has_many :user_route_discounts
  has_many :routes, foreign_key: :customer_id
  has_many :pricings, foreign_key: :customer_id

  has_many :contacts
  has_many :consignees, through: :contacts
  has_many :notifyees, through: :contacts

  has_many :user_managers
  has_many :pricings

  PERMITTED_PARAMS = [
    :email, :password,
    :guest, :tenant_id, :confirm_password, :password_confirmation,
    :company_name, :vat_number, :VAT_number, :first_name, :last_name, :phone,
    :cookie_consent
  ]

  # Filterrific
  filterrific :default_filter_params => { :sorted_by => 'created_at_asc' },
              :available_filters => %w(
                sorted_by
                search_query
              )
  self.per_page = 10 # default for will_paginate

  scope :search_query, lambda { |query|
    return nil if query.blank?
    # condition query, parse into individual keywords
    terms = query.to_s.gsub(',', '').downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # prepend and append '%', remove duplicate '%'s
    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }

    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 3

    or_clauses = [
      "users.first_name ILIKE ?",
      "users.last_name ILIKE ?",
      "users.email ILIKE ?"
    ].join(' OR ')

    where(
      terms.map { "(#{or_clauses})" }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
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

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_and_company
    "#{first_name} #{last_name}, #{company_name}"
  end

  def full_name_and_company_and_address
    "#{first_name} #{last_name}\n#{company_name}\n#{location.geocoded_address}"
  end

  def decorated_created_at
    created_at.to_date.to_s(:long)
  end

  def primary_location
    user_locations.where(primary: true).first.try(:location)
  end

  def secondary_locations
    user_locations.where(primary: false).map(&:location)
  end


  # override devise method to include additional info as opts hash
  def send_confirmation_instructions(opts={})
    return if self.guest
    generate_confirmation_token! unless @raw_confirmation_token

    # fall back to "default" config name
    opts[:client_config] ||= "default"
    opts[:to] = unconfirmed_email if pending_reconfirmation?
    opts[:redirect_url] ||= DeviseTokenAuth.default_confirm_success_url

    send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
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
   self.currency = self.tenant.currency
  end

  def clear_tokens_if_empty
   self.tokens = nil if tokens == "{}"
  end

  def sync_uid
    self.uid = "#{tenant.id}***#{email}"
  end

  def update_shipments
    self.shipments.requested_by_unconfirmed_account.each do |shipment|
      shipment.status = "requested"
      shipment.save
    end
  end
  def gdpr_delete
    self.gdpr_status = 'deleted'
  end
  protected

  def confirmation_required?
    false
  end
end
