# frozen_string_literal: true

FactoryBot.define do
  factory :shipment_contact do
    association :contact
    association :shipment
    contact_type { :shipper }
  end
end

# == Schema Information
#
# Table name: shipment_contacts
#
#  id           :bigint           not null, primary key
#  contact_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  contact_id   :integer
#  sandbox_id   :uuid
#  shipment_id  :integer
#
# Indexes
#
#  index_shipment_contacts_on_sandbox_id  (sandbox_id)
#
