module Journey
  class Contact < ApplicationRecord
    belongs_to :shipment_request
    belongs_to :original, class_name: "AddressBook::Contact"

    validates :company_name, presence: true
    validates :name, presence: true
    validates :phone, presence: true
    validates :email, presence: true
    validates :address_line_1, presence: true
    validates :postal_code, presence: true
    validates :city, presence: true
    validates :country_code, presence: true
  end
end

# == Schema Information
#
# Table name: journey_contacts
#
#  id                  :uuid             not null, primary key
#  address_line_1      :string           default(""), not null
#  address_line_2      :string           default(""), not null
#  address_line_3      :string           default(""), not null
#  city                :string           default(""), not null
#  company_name        :string           default(""), not null
#  country_code        :string           not null
#  email               :string           default(""), not null
#  function            :string           not null
#  geocoded_address    :string
#  name                :string           not null
#  phone               :string           default(""), not null
#  point               :geometry         not null, geometry, 4326
#  postal_code         :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  original_id         :uuid             not null
#  shipment_request_id :uuid
#
# Indexes
#
#  index_journey_contacts_on_shipment_request_id  (shipment_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (shipment_request_id => journey_shipment_requests.id) ON DELETE => cascade
#
