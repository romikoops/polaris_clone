# frozen_string_literal: true

module AddressBook
  class Contact < ApplicationRecord
    include PgSearch::Model
    has_paper_trail unless: proc { |t| t.sandbox_id.present? }

    pg_search_scope :contact_search, against: %i(first_name last_name company_name email phone country_code), using: {
      tsearch: { prefix: true }
    }

    belongs_to :user, class_name: 'Tenants::User'
    has_many :shipment_request_contacts, class_name: 'Shipments::ShipmentRequestContact'

    # Validations
    validates :first_name, :email, presence: true

    # validates uniqueness for each user
    validates :user_id, uniqueness: { scope: %i(first_name last_name phone email),
                                      message: 'Contact must be unique to add.' }
  end
end

# == Schema Information
#
# Table name: address_book_contacts
#
#  id               :uuid             not null, primary key
#  user_id          :integer
#  company_name     :string
#  first_name       :string
#  last_name        :string
#  phone            :string
#  email            :string
#  sandbox_id       :uuid
#  latitude         :float
#  longitude        :float
#  geocoded_address :string
#  street           :string
#  street_number    :string
#  zip_code         :string
#  city             :string
#  province         :string
#  premise          :string
#  country_code     :string
#  country_name     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
