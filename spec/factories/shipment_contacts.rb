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
#  shipment_id  :integer
#  contact_id   :integer
#  contact_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sandbox_id   :uuid
#
