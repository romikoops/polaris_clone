# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_contact, class: "Shipments::Contact" do
    sequence(:first_name) { |n| "John#{n}" }
    sequence(:last_name) { |n| "Smith#{n}" }
    sequence(:phone) { |n| "1234567#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }

    company_name { "Example Company" }
    latitude { "57.694253" }
    longitude { "11.854048" }
    post_code { "43813" }
    geocoded_address { "438 80 Landvetter, Sweden" }
    city { "Gothenburg" }
    country_code { "SE" }

    trait :consignee do
      contact_type { "consignee" }
    end

    trait :consignor do
      contact_type { "consignor" }
    end

    trait :notifyee do
      contact_type { "notifyee" }
    end
  end
end

# == Schema Information
#
# Table name: shipments_contacts
#
#  id               :uuid             not null, primary key
#  city             :string
#  company_name     :string
#  contact_type     :integer
#  country_code     :string
#  country_name     :string
#  email            :string
#  first_name       :string
#  geocoded_address :string
#  last_name        :string
#  latitude         :float
#  longitude        :float
#  phone            :string
#  post_code        :string
#  premise          :string
#  province         :string
#  street           :string
#  street_number    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  sandbox_id       :uuid
#  shipment_id      :uuid             not null
#
# Indexes
#
#  index_shipments_contacts_on_sandbox_id   (sandbox_id)
#  index_shipments_contacts_on_shipment_id  (shipment_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
