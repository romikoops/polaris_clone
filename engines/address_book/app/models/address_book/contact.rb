# frozen_string_literal: true

module AddressBook
  class Contact < ApplicationRecord
    include PgSearch::Model
    has_paper_trail

    pg_search_scope :contact_search, against: %i[first_name last_name company_name email phone country_code], using: {
      tsearch: { prefix: true }
    }

    belongs_to :user, class_name: 'Organizations::User'
    has_many :shipment_request_contacts, class_name: 'Shipments::ShipmentRequestContact'

    # Validations
    validates :first_name, :email, presence: true

    # validates uniqueness for each user
    validates :user_id, uniqueness: { scope: %i[first_name last_name phone email],
                                      message: 'Contact must be unique to add.' }
  end
end

# == Schema Information
#
# Table name: address_book_contacts
#
#  id               :uuid             not null, primary key
#  city             :string
#  company_name     :string
#  country_code     :string
#  email            :string
#  first_name       :string
#  geocoded_address :string
#  last_name        :string
#  phone            :string
#  point            :geometry         geometry, 0
#  postal_code      :string
#  premise          :string
#  province         :string
#  street           :string
#  street_number    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  legacy_user_id   :uuid
#  sandbox_id       :uuid
#  tms_id           :string
#  user_id          :uuid
#
# Indexes
#
#  index_address_book_contacts_on_legacy_user_id  (legacy_user_id)
#  index_address_book_contacts_on_sandbox_id      (sandbox_id)
#  index_address_book_contacts_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#  fk_rails_...  (user_id => users_users.id)
#
