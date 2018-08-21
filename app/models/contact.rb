# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :user
  has_many :shipment_contacts
  belongs_to :location, optional: true

  # Validations
  # validates :company_name, presence: true, length: { in: 2..50 }
  validates :first_name,   presence: true, length: { in: 2..50 }
  validates :last_name,    presence: true, length: { in: 2..50 }
  validates :phone,        presence: true, length: { minimum: 3 }
  validates :email,        presence: true, length: { minimum: 3 }

  # validates uniqueness for each user
  validates :user_id, uniqueness: { scope:   %i(first_name last_name phone email),
                                    message: "Contact must be unique to add." }

  # Filterrific configuration
  filterrific default_filter_params: { sorted_by: "created_at_asc" },
              available_filters:     %w(
                sorted_by
                search_query
              )

  self.per_page = 6 # default for will_paginate

  scope :search_query, lambda { |query|
    return nil if query.blank?
    # condition query, parse into individual keywords
    terms = query.to_s.delete(",").downcase.split(/\s+/)
    # replace "*" with "%" for wildcard searches,
    # prepend and append '%', remove duplicate '%'s
    terms = terms.map do |e|
      ("%" + e.tr("*", "%") + "%").gsub(/%+/, "%")
    end

    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conditions = 3

    or_clauses = [
      "consignees.first_name ILIKE ?",
      "consignees.last_name ILIKE ?",
      "consignees.company_name ILIKE ?"
    ].join(" OR ")

    where(
      terms.map { "(#{or_clauses})" }.join(" AND "),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"
    case sort_option.to_s
    when /^created_at_/
      order("consignees.created_at #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  # Class methods
  def self.options_for_sorted_by
    [
      ["Registration date (newest first)", "created_at_desc"],
      ["Registration date (oldest first)", "created_at_asc"]
    ]
  end

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def as_options_json(options={})
    new_options = options.reverse_merge(
      include: {
        location: {
          include: {
            country: { only: :name }
          },
          except:  %i(created_at updated_at country_id)
        }
      },
      except:  %i(created_at updated_at location_id)
    )

    as_json(new_options)
  end

  def full_name_and_company
    "#{first_name} #{last_name}, #{company_name}"
  end

  def full_name_and_company_and_address
    address_if_exists = location.nil? ? "" : "\n#{location.geocoded_address}"
    "#{first_name} #{last_name} #{company_name}#{address_if_exists}"
  end
end
