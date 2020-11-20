# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_shipment_request_contact, class: "Shipments::ShipmentRequestContact" do
    association :shipment_request, factory: :shipments_shipment_request

    after(:build) do |request|
      request.contact = create(:address_book_contact)
    end

    trait :as_consignee do
      initialize_with { Shipments::ShipmentRequestContacts::Consignee.new }
    end

    trait :as_consignor do
      initialize_with { Shipments::ShipmentRequestContacts::Consignor.new }
    end

    trait :as_notifyee do
      initialize_with { Shipments::ShipmentRequestContacts::Notifyee.new }
    end
  end
end

# == Schema Information
#
# Table name: shipments_shipment_request_contacts
#
#  id                  :uuid             not null, primary key
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  contact_id          :uuid             not null
#  shipment_request_id :uuid             not null
#
# Indexes
#
#  index_shipment_request_contacts_on_contact_id           (contact_id)
#  index_shipment_request_contacts_on_shipment_request_id  (shipment_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => address_book_contacts.id)
#
