class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable

  include DeviseTokenAuth::Concerns::User
  
  before_create :set_default_role
  validates :tenant_id, presence: true

  # Basic associations
  belongs_to :tenant
  belongs_to :role

  has_many :user_locations, dependent: :destroy
  has_many :locations, through: :user_locations

  has_many :shipments, foreign_key: "shipper_id"
  has_many :receivable_shipments, foreign_key: "consignee_id"

  # belongs_to :notifying_shipment, class_name: "Shipment"

  has_many :user_route_discounts
  has_many :routes, foreign_key: :customer_id
  has_many :pricings, foreign_key: :customer_id

  has_many :contacts, foreign_key: :shipper_id
  has_many :consignees, through: :contacts
  has_many :notifyees, through: :contacts

  # Devise
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable, :trackable, :confirmable

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

  def main_location
    u_loc = user_locations.where(primary: true).first
    if !u_loc 
      return Location.new(street: "",
          zip_code: "",
          city: "",
          country: "")
    else
      return u_loc.location
    end
    
  end

  def secondary_locations
    user_locations.where(primary: false).map(&:location)
  end
  
  private

  def set_default_role
    self.role ||= Role.find_by_name('shipper')
  end
end
