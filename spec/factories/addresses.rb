# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    name { "Gothenburg" }
    latitude { "57.694253" }
    longitude { "11.854048" }
    zip_code { "43813" }
    geocoded_address { "438 80 Landvetter, Sweden" }
    city { "Gothenburg" }
    association :country
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  city             :string
#  geocoded_address :string
#  latitude         :float
#  location_type    :string
#  longitude        :float
#  name             :string
#  photo            :string
#  premise          :string
#  province         :string
#  street           :string
#  street_address   :string
#  street_number    :string
#  zip_code         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  country_id       :integer
#  sandbox_id       :uuid
#
# Indexes
#
#  index_addresses_on_sandbox_id  (sandbox_id)
#
