# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    name { 'Gothenburg' }
    latitude { '57.694253' }
    longitude { '11.854048' }
    zip_code { '43813' }
    geocoded_address { '438 80 Landvetter, Sweden' }
    city { 'Gothenburg' }
    association :country
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id               :bigint(8)        not null, primary key
#  name             :string
#  location_type    :string
#  latitude         :float
#  longitude        :float
#  geocoded_address :string
#  street           :string
#  street_number    :string
#  zip_code         :string
#  city             :string
#  street_address   :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  province         :string
#  photo            :string
#  premise          :string
#  country_id       :integer
#
