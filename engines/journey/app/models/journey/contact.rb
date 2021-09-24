# frozen_string_literal: true

module Journey
  class Contact < ApplicationRecord
    belongs_to :shipment_request
    belongs_to :original, class_name: "AddressBook::Contact", optional: true
  end
end

# == Schema Information
#
# Table name: journey_contacts
#
#  id                  :uuid             not null, primary key
#  address_line_1      :string
#  address_line_2      :string
#  address_line_3      :string
#  city                :string
#  company_name        :string
#  country_code        :string
#  email               :string
#  function            :string
#  geocoded_address    :string
#  name                :string
#  phone               :string
#  point               :geometry         geometry, 4326
#  postal_code         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  original_id         :uuid
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
